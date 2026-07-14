package com.poly.controller;

import com.poly.entity.*;
import com.poly.repository.*;
import com.poly.service.APIPayService;
import com.poly.service.PayOSService;
import jakarta.servlet.http.HttpSession;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private APIPayService apiPayService;

    @Autowired
    private PayOSService payOSService;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private OrderItemRepository orderItemRepository;

    @Autowired
    private CartItemRepository cartItemRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductVariantRepository productVariantRepository;

    @Autowired
    private PromotionRepository promotionRepository;

    @Data
    public static class OrderRequest {
        private String fullName;
        private String phone;
        private String address;
        private String notes;
        private String paymentMethod; // 'COD', 'BANK_TRANSFER'
        private String voucherCode;
    }

    @PostMapping
    @Transactional
    public ResponseEntity<?> createOrder(@RequestBody OrderRequest request, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Vui lòng đăng nhập để thanh toán."));
        }

        // 1. Fetch user's cart items
        List<CartItem> cartItems = cartItemRepository.findByUserId(currentUser.getId());
        if (cartItems.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Giỏ hàng của bạn đang trống."));
        }

        // Calculate subtotal and validate items/stock
        BigDecimal subtotal = BigDecimal.ZERO;
        List<ProductVariant> variantsToUpdate = new ArrayList<>();
        List<OrderItem> orderItems = new ArrayList<>();

        for (CartItem ci : cartItems) {
            Optional<Product> productOpt = productRepository.findById(ci.getProductId());
            Optional<ProductVariant> variantOpt = productVariantRepository.findById(ci.getVariantId());

            if (productOpt.isEmpty() || variantOpt.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("message", "Một số sản phẩm trong giỏ hàng không hợp lệ."));
            }

            Product p = productOpt.get();
            ProductVariant pv = variantOpt.get();

            // Validate stock
            if (pv.getStock() < ci.getQuantity()) {
                return ResponseEntity.badRequest().body(Map.of(
                        "message", "Sản phẩm \"" + p.getName() + "\" (" + pv.getSize() + ", " + pv.getColor() + ") chỉ còn " + pv.getStock() + " sản phẩm trong kho."
                ));
            }

            // Deduct stock temporarily (will be saved in DB on successful transaction commit)
            pv.setStock(pv.getStock() - ci.getQuantity());
            variantsToUpdate.add(pv);

            // Compute subtotal
            BigDecimal itemTotalPrice = p.getPrice().multiply(BigDecimal.valueOf(ci.getQuantity()));
            subtotal = subtotal.add(itemTotalPrice);

            // Build OrderItem
            OrderItem oi = new OrderItem();
            oi.setProductId(p.getId());
            oi.setVariantId(pv.getId());
            oi.setProductName(p.getName());
            oi.setSize(pv.getSize());
            oi.setColor(pv.getColor());
            oi.setPrice(p.getPrice());
            oi.setQuantity(ci.getQuantity());
            oi.setTotalPrice(itemTotalPrice);
            orderItems.add(oi);
        }

        // Apply Promotion if present
        BigDecimal discount = BigDecimal.ZERO;
        if (request.getVoucherCode() != null && !request.getVoucherCode().trim().isEmpty()) {
            Optional<Promotion> promoOpt = promotionRepository.findByCode(request.getVoucherCode().trim());
            if (promoOpt.isPresent()) {
                Promotion voucher = promoOpt.get();
                // Basic checks
                if (Boolean.TRUE.equals(voucher.getActive()) && subtotal.compareTo(voucher.getMinOrderValue()) >= 0) {
                    if ("PERCENTAGE".equals(voucher.getDiscountType())) {
                        BigDecimal calcDiscount = subtotal.multiply(voucher.getDiscountValue().divide(new BigDecimal("100")));
                        if (voucher.getMaxDiscount() != null && calcDiscount.compareTo(voucher.getMaxDiscount()) > 0) {
                            discount = voucher.getMaxDiscount();
                        } else {
                            discount = calcDiscount;
                        }
                    } else if ("FIXED_AMOUNT".equals(voucher.getDiscountType())) {
                        discount = voucher.getDiscountValue();
                    }
                }
            }
        }

        BigDecimal total = subtotal.subtract(discount);
        if (total.compareTo(BigDecimal.ZERO) < 0) {
            total = BigDecimal.ZERO;
        }

        // Save order
        Order order = new Order();
        order.setOrderCode("TDF" + System.currentTimeMillis() / 1000);
        order.setUserId(currentUser.getId());
        order.setFullName(request.getFullName());
        order.setPhone(request.getPhone());
        order.setAddress(request.getAddress());
        order.setNotes(request.getNotes());
        order.setPaymentMethod(request.getPaymentMethod());
        order.setPaymentStatus("UNPAID");
        order.setShippingFee(BigDecimal.ZERO);
        order.setDiscountAmount(discount);
        order.setTotalAmount(total);
        order.setStatus("PENDING");

        Order savedOrder = orderRepository.save(order);

        // Save order items & save variant stocks
        for (OrderItem oi : orderItems) {
            oi.setOrderId(savedOrder.getId());
            orderItemRepository.save(oi);
        }
        productVariantRepository.saveAll(variantsToUpdate);

        // Clear cart
        cartItemRepository.deleteByUserId(currentUser.getId());

        // Create PayOS payment link if BANK_TRANSFER
        if ("BANK_TRANSFER".equals(savedOrder.getPaymentMethod())) {
            try {
                String cleanCode = savedOrder.getOrderCode().substring(3);
                Long payosOrderCode = Long.parseLong(cleanCode);
                String payUrl = payOSService.createPaymentLink(payosOrderCode, savedOrder.getTotalAmount().doubleValue());
                if (payUrl != null) {
                    savedOrder.setPayUrl(payUrl);
                    orderRepository.save(savedOrder);
                }
            } catch (Exception e) {
                System.err.println("Error generating PayOS link: " + e.getMessage());
            }
        }

        return ResponseEntity.status(HttpStatus.CREATED).body(savedOrder);
    }

    @GetMapping
    public ResponseEntity<?> getOrderHistory(HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Chưa đăng nhập."));
        }
        List<Order> orders = orderRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId());
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOrderDetail(@PathVariable Integer id, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Chưa đăng nhập."));
        }

        Optional<Order> orderOpt = orderRepository.findById(id);
        if (orderOpt.isPresent()) {
            Order order = orderOpt.get();
            // Validate that the order belongs to current user OR user is Admin/Employee
            if (!order.getUserId().equals(currentUser.getId()) && !"ADMIN".equals(currentUser.getRole()) && !"EMPLOYEE".equals(currentUser.getRole())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Bạn không có quyền xem đơn hàng này."));
            }

            List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
            // Enrich order items with image URL if needed
            for (OrderItem item : items) {
                productRepository.findById(item.getProductId()).ifPresent(p -> item.setProductImageUrl(p.getImageUrl()));
            }
            order.setItems(items);
            return ResponseEntity.ok(order);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Đơn hàng không tồn tại."));
    }

    @PostMapping("/simulate-payment/{orderCode}")
    @Transactional
    public ResponseEntity<?> simulatePayment(@PathVariable String orderCode) {
        Optional<Order> orderOpt = orderRepository.findByOrderCode(orderCode);
        if (orderOpt.isPresent()) {
            Order order = orderOpt.get();
            order.setPaymentStatus("PAID");
            order.setStatus("CONFIRMED");
            Order saved = orderRepository.save(order);
            return ResponseEntity.ok(saved);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Đơn hàng không tồn tại."));
    }
}

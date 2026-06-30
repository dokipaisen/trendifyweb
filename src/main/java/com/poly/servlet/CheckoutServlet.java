package com.poly.servlet;

import com.poly.dao.CartDao;
import com.poly.dao.OrderDao;
import com.poly.entity.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private final CartDao cartDao = new CartDao();
    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<CartItem> cartItems = cartDao.findByUserId(currentUser.getId());
        if (cartItems.isEmpty()) {
            session.setAttribute("cartError", "Giỏ hàng của bạn đang trống, không thể thanh toán.");
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            subtotal = subtotal.add(item.getTotalPrice());
        }

        Promotion voucher = (Promotion) session.getAttribute("appliedVoucher");
        BigDecimal discount = BigDecimal.ZERO;
        if (voucher != null) {
            if (subtotal.compareTo(voucher.getMinOrderValue()) >= 0) {
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

        BigDecimal total = subtotal.subtract(discount);
        if (total.compareTo(BigDecimal.ZERO) < 0) {
            total = BigDecimal.ZERO;
        }

        String orderCode = "TDF" + System.currentTimeMillis() / 1000;

        req.setAttribute("cartItems", cartItems);
        req.setAttribute("cartSubtotal", subtotal);
        req.setAttribute("discountAmount", discount);
        req.setAttribute("cartTotal", total);
        req.setAttribute("orderCode", orderCode);

        req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<CartItem> cartItems = cartDao.findByUserId(currentUser.getId());
        if (cartItems.isEmpty()) {
            session.setAttribute("cartError", "Giỏ hàng của bạn đang trống.");
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");
        String notes = req.getParameter("notes");
        String paymentMethod = req.getParameter("paymentMethod");
        String orderCode = req.getParameter("orderCode");

        // Calculations
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            subtotal = subtotal.add(item.getTotalPrice());
        }

        Promotion voucher = (Promotion) session.getAttribute("appliedVoucher");
        BigDecimal discount = BigDecimal.ZERO;
        if (voucher != null) {
            if (subtotal.compareTo(voucher.getMinOrderValue()) >= 0) {
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

        BigDecimal total = subtotal.subtract(discount);
        if (total.compareTo(BigDecimal.ZERO) < 0) {
            total = BigDecimal.ZERO;
        }

        Order order = new Order();
        order.setOrderCode(orderCode);
        order.setUserId(currentUser.getId());
        order.setFullName(fullName);
        order.setPhone(phone);
        order.setAddress(address);
        order.setNotes(notes);
        order.setPaymentMethod(paymentMethod);
        order.setPaymentStatus("UNPAID");
        order.setShippingFee(BigDecimal.ZERO);
        order.setDiscountAmount(discount);
        order.setTotalAmount(total);
        order.setStatus("PENDING");

        List<OrderItem> items = new ArrayList<>();
        for (CartItem ci : cartItems) {
            OrderItem oi = new OrderItem();
            oi.setProductId(ci.getProductId());
            oi.setVariantId(ci.getVariantId());
            oi.setProductName(ci.getProductName());
            oi.setSize(ci.getSize());
            oi.setColor(ci.getColor());
            oi.setPrice(ci.getPrice());
            oi.setQuantity(ci.getQuantity());
            oi.setTotalPrice(ci.getTotalPrice());
            items.add(oi);
        }

        boolean success = orderDao.createOrder(order, items);
        if (success) {
            session.removeAttribute("appliedVoucher");
            session.setAttribute("cartSize", 0);
            session.setAttribute("profileSuccess", "Đặt hàng thành công! Cảm ơn bạn đã mua sắm tại Trendify.");
            resp.sendRedirect(req.getContextPath() + "/profile");
        } else {
            session.setAttribute("checkoutError", "Đặt hàng thất bại. Có thể một số sản phẩm trong giỏ hàng đã hết số lượng tồn kho. Vui lòng kiểm tra lại giỏ hàng.");
            resp.sendRedirect(req.getContextPath() + "/checkout");
        }
    }
}

package com.poly.controller;

import com.poly.entity.CartItem;
import com.poly.entity.Product;
import com.poly.entity.ProductVariant;
import com.poly.entity.User;
import com.poly.repository.CartItemRepository;
import com.poly.repository.ProductRepository;
import com.poly.repository.ProductVariantRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/cart")
public class CartController {

    @Autowired
    private CartItemRepository cartItemRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductVariantRepository productVariantRepository;

    private List<CartItem> enrichCartItems(List<CartItem> items) {
        List<CartItem> enriched = new ArrayList<>();
        for (CartItem item : items) {
            Optional<Product> productOpt = productRepository.findById(item.getProductId());
            Optional<ProductVariant> variantOpt = productVariantRepository.findById(item.getVariantId());
            
            if (productOpt.isPresent() && variantOpt.isPresent()) {
                Product p = productOpt.get();
                ProductVariant pv = variantOpt.get();
                
                item.setProductName(p.getName());
                item.setProductBrand(p.getBrand());
                item.setProductImageUrl(p.getImageUrl());
                item.setPrice(p.getPrice());
                item.setSize(pv.getSize());
                item.setColor(pv.getColor());
                enriched.add(item);
            }
        }
        return enriched;
    }

    @GetMapping
    public ResponseEntity<?> getCart(HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Chưa đăng nhập."));
        }
        List<CartItem> items = cartItemRepository.findByUserId(currentUser.getId());
        return ResponseEntity.ok(enrichCartItems(items));
    }

    @PostMapping("/add")
    public ResponseEntity<?> addToCart(@RequestBody CartItem item, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Chưa đăng nhập."));
        }

        Optional<ProductVariant> variantOpt = productVariantRepository.findById(item.getVariantId());
        if (variantOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Biến thể sản phẩm không tồn tại."));
        }

        item.setUserId(currentUser.getId());
        
        Optional<CartItem> existingOpt = cartItemRepository.findByUserIdAndVariantId(currentUser.getId(), item.getVariantId());
        if (existingOpt.isPresent()) {
            CartItem existing = existingOpt.get();
            existing.setQuantity(existing.getQuantity() + item.getQuantity());
            cartItemRepository.save(existing);
        } else {
            cartItemRepository.save(item);
        }

        return ResponseEntity.ok(Map.of("message", "Đã thêm vào giỏ hàng thành công."));
    }

    @PostMapping("/merge")
    @Transactional
    public ResponseEntity<?> mergeCart(@RequestBody List<CartItem> guestItems, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Chưa đăng nhập."));
        }

        for (CartItem guestItem : guestItems) {
            Optional<CartItem> existingOpt = cartItemRepository.findByUserIdAndVariantId(currentUser.getId(), guestItem.getVariantId());
            if (existingOpt.isPresent()) {
                CartItem existing = existingOpt.get();
                existing.setQuantity(existing.getQuantity() + guestItem.getQuantity());
                cartItemRepository.save(existing);
            } else {
                guestItem.setUserId(currentUser.getId());
                guestItem.setId(null); // Clear transient ID
                cartItemRepository.save(guestItem);
            }
        }
        return ResponseEntity.ok(Map.of("message", "Đã hợp nhất giỏ hàng thành công."));
    }

    @PutMapping("/quantity")
    public ResponseEntity<?> updateQuantity(
            @RequestParam Integer variantId,
            @RequestParam Integer quantity,
            HttpSession session
    ) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Chưa đăng nhập."));
        }

        if (quantity <= 0) {
            return ResponseEntity.badRequest().body(Map.of("message", "Số lượng phải lớn hơn 0."));
        }

        Optional<CartItem> existingOpt = cartItemRepository.findByUserIdAndVariantId(currentUser.getId(), variantId);
        if (existingOpt.isPresent()) {
            CartItem item = existingOpt.get();
            item.setQuantity(quantity);
            cartItemRepository.save(item);
            return ResponseEntity.ok(Map.of("message", "Cập nhật số lượng thành công."));
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Sản phẩm không có trong giỏ hàng."));
    }

    @DeleteMapping("/remove")
    @Transactional
    public ResponseEntity<?> removeFromCart(@RequestParam Integer variantId, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Chưa đăng nhập."));
        }
        cartItemRepository.deleteByUserIdAndVariantId(currentUser.getId(), variantId);
        return ResponseEntity.ok(Map.of("message", "Đã xoá sản phẩm khỏi giỏ hàng."));
    }

    @DeleteMapping("/clear")
    @Transactional
    public ResponseEntity<?> clearCart(HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Chưa đăng nhập."));
        }
        cartItemRepository.deleteByUserId(currentUser.getId());
        return ResponseEntity.ok(Map.of("message", "Đã làm trống giỏ hàng."));
    }
}

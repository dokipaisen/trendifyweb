package com.poly.controller;

import com.poly.entity.*;
import com.poly.repository.*;
import com.poly.utils.PasswordUtils;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductImageRepository productImageRepository;

    @Autowired
    private ProductVariantRepository productVariantRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private OrderItemRepository orderItemRepository;

    @Autowired
    private PromotionRepository promotionRepository;

    @Autowired
    private BannerRepository bannerRepository;

    // Helper to check admin/staff session and role
    private boolean checkRole(HttpSession session, List<String> allowedRoles) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return false;
        return allowedRoles.contains(currentUser.getRole());
    }

    private User getSessionUser(HttpSession session) {
        return (User) session.getAttribute("currentUser");
    }

    // --- Upload File API ---
    @PostMapping("/upload")
    public ResponseEntity<?> uploadFile(@RequestParam("file") MultipartFile file, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "File rỗng."));
        }

        try {
            File uploadDir = new File("uploads");
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String originalFilename = file.getOriginalFilename();
            String fileExtension = originalFilename != null && originalFilename.contains(".") ? originalFilename.substring(originalFilename.lastIndexOf(".")) : ".jpg";
            String newFilename = UUID.randomUUID().toString() + fileExtension;
            
            File dest = new File(uploadDir.getAbsolutePath() + File.separator + newFilename);
            file.transferTo(dest);

            String url = "/uploads/" + newFilename;
            return ResponseEntity.ok(Map.of("url", url));
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("message", "Lỗi tải tệp lên."));
        }
    }

    // --- Statistics API (Only ADMIN) ---
    @GetMapping("/statistics")
    public ResponseEntity<?> getStatistics(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) Integer month,
            @RequestParam(required = false) Integer year,
            HttpSession session
    ) {
        if (!checkRole(session, List.of("ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Chức năng này yêu cầu quyền Admin."));
        }

        List<Order> orders = orderRepository.findAll();
        BigDecimal totalRevenue = BigDecimal.ZERO;
        long totalOrders = 0;

        for (Order o : orders) {
            if ("CANCELLED".equals(o.getStatus())) continue;
            
            LocalDateTime odt = o.getCreatedAt().toLocalDateTime();
            boolean match = true;

            if (startDate != null && odt.toLocalDate().isBefore(startDate)) match = false;
            if (endDate != null && odt.toLocalDate().isAfter(endDate)) match = false;
            if (month != null && odt.getMonthValue() != month) match = false;
            if (year != null && odt.getYear() != year) match = false;

            if (match) {
                totalRevenue = totalRevenue.add(o.getTotalAmount());
                totalOrders++;
            }
        }

        // Employee performance grouping
        Map<String, Map<String, Object>> staffPerformance = new HashMap<>();
        for (Order o : orders) {
            if ("CANCELLED".equals(o.getStatus()) || o.getEmployeeId() == null) continue;
            
            LocalDateTime odt = o.getCreatedAt().toLocalDateTime();
            boolean match = true;

            if (startDate != null && odt.toLocalDate().isBefore(startDate)) match = false;
            if (endDate != null && odt.toLocalDate().isAfter(endDate)) match = false;
            if (month != null && odt.getMonthValue() != month) match = false;
            if (year != null && odt.getYear() != year) match = false;

            if (match) {
                Optional<User> staffOpt = userRepository.findById(o.getEmployeeId());
                if (staffOpt.isPresent()) {
                    String name = staffOpt.get().getFullName();
                    Map<String, Object> perf = staffPerformance.computeIfAbsent(name, k -> new HashMap<>(Map.of("revenue", BigDecimal.ZERO, "ordersCount", 0L)));
                    perf.put("revenue", ((BigDecimal) perf.get("revenue")).add(o.getTotalAmount()));
                    perf.put("ordersCount", ((long) perf.get("ordersCount")) + 1);
                }
            }
        }

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalRevenue", totalRevenue);
        stats.put("totalOrders", totalOrders);
        stats.put("staffPerformance", staffPerformance);

        return ResponseEntity.ok(stats);
    }

    // --- Order Management API (ADMIN & EMPLOYEE) ---
    @GetMapping("/orders")
    public ResponseEntity<?> getFilteredOrders(
            @RequestParam(required = false) Integer employeeId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) Integer month,
            @RequestParam(required = false) Integer year,
            HttpSession session
    ) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        List<Order> allOrders = orderRepository.findAll();
        List<Order> filtered = new ArrayList<>();

        for (Order o : allOrders) {
            LocalDateTime odt = o.getCreatedAt().toLocalDateTime();
            boolean match = true;

            if (employeeId != null && !employeeId.equals(o.getEmployeeId())) match = false;
            if (startDate != null && odt.toLocalDate().isBefore(startDate)) match = false;
            if (endDate != null && odt.toLocalDate().isAfter(endDate)) match = false;
            if (month != null && odt.getMonthValue() != month) match = false;
            if (year != null && odt.getYear() != year) match = false;

            if (match) {
                filtered.add(o);
            }
        }

        // Sort descending by created_at
        filtered.sort((o1, o2) -> o2.getCreatedAt().compareTo(o1.getCreatedAt()));
        return ResponseEntity.ok(filtered);
    }

    @PutMapping("/orders/{id}/status")
    public ResponseEntity<?> updateOrderStatus(
            @PathVariable Integer id,
            @RequestParam String status,
            @RequestParam String paymentStatus,
            HttpSession session
    ) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        Optional<Order> orderOpt = orderRepository.findById(id);
        if (orderOpt.isPresent()) {
            Order order = orderOpt.get();
            order.setStatus(status);
            order.setPaymentStatus(paymentStatus);
            order.setEmployeeId(getSessionUser(session).getId());
            Order saved = orderRepository.save(order);
            return ResponseEntity.ok(saved);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy đơn hàng."));
    }

    // --- Product Management CRUD API ---
    @PostMapping("/products")
    @Transactional
    public ResponseEntity<?> createProduct(@RequestBody Product product, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        if (product.getRating() == null) product.setRating(BigDecimal.valueOf(5.0));
        if (product.getStatus() == null) product.setStatus("ACTIVE");

        Product saved = productRepository.save(product);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/products/{id}")
    @Transactional
    public ResponseEntity<?> updateProduct(@PathVariable Integer id, @RequestBody Product productUpdates, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        Optional<Product> prodOpt = productRepository.findById(id);
        if (prodOpt.isPresent()) {
            Product existing = prodOpt.get();
            existing.setName(productUpdates.getName());
            existing.setDescription(productUpdates.getDescription());
            existing.setPrice(productUpdates.getPrice());
            existing.setOriginalPrice(productUpdates.getOriginalPrice());
            existing.setBrand(productUpdates.getBrand());
            existing.setImageUrl(productUpdates.getImageUrl());
            existing.setCategoryId(productUpdates.getCategoryId());
            existing.setStatus(productUpdates.getStatus());
            
            Product saved = productRepository.save(existing);
            return ResponseEntity.ok(saved);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy sản phẩm."));
    }

    @DeleteMapping("/products/{id}")
    @Transactional
    public ResponseEntity<?> deleteProduct(@PathVariable Integer id, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        if (productRepository.existsById(id)) {
            productRepository.deleteById(id);
            return ResponseEntity.ok(Map.of("message", "Xóa sản phẩm thành công."));
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy sản phẩm."));
    }

    // --- Product Image Management ---
    @PostMapping("/products/{id}/images")
    public ResponseEntity<?> addProductImage(@PathVariable Integer id, @RequestParam String imageUrl, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        ProductImage img = new ProductImage();
        img.setProductId(id);
        img.setImageUrl(imageUrl);
        ProductImage saved = productImageRepository.save(img);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @DeleteMapping("/products/{id}/images")
    @Transactional
    public ResponseEntity<?> clearProductImages(@PathVariable Integer id, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }
        productImageRepository.deleteByProductId(id);
        return ResponseEntity.ok(Map.of("message", "Xóa ảnh phụ thành công."));
    }

    // --- Product Variant Management ---
    @PostMapping("/products/{id}/variants")
    @Transactional
    public ResponseEntity<?> saveProductVariants(@PathVariable Integer id, @RequestBody List<ProductVariant> variants, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        // Remove old variants
        List<ProductVariant> existing = productVariantRepository.findByProductId(id);
        productVariantRepository.deleteAll(existing);

        // Save new variants
        for (ProductVariant pv : variants) {
            pv.setProductId(id);
            pv.setId(null); // Force new creation
            productVariantRepository.save(pv);
        }

        return ResponseEntity.ok(Map.of("message", "Lưu biến thể sản phẩm thành công."));
    }

    // --- Category Management CRUD API (ADMIN & EMPLOYEE) ---
    @PostMapping("/categories")
    public ResponseEntity<?> createCategory(@RequestBody Category category, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }
        Category saved = categoryRepository.save(category);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/categories/{id}")
    public ResponseEntity<?> updateCategory(@PathVariable Integer id, @RequestBody Category categoryUpdates, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        Optional<Category> catOpt = categoryRepository.findById(id);
        if (catOpt.isPresent()) {
            Category existing = catOpt.get();
            existing.setName(categoryUpdates.getName());
            existing.setDescription(categoryUpdates.getDescription());
            existing.setImageUrl(categoryUpdates.getImageUrl());
            Category saved = categoryRepository.save(existing);
            return ResponseEntity.ok(saved);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy danh mục."));
    }

    @DeleteMapping("/categories/{id}")
    public ResponseEntity<?> deleteCategory(@PathVariable Integer id, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        if (categoryRepository.existsById(id)) {
            categoryRepository.deleteById(id);
            return ResponseEntity.ok(Map.of("message", "Xóa danh mục thành công."));
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy danh mục."));
    }

    // --- User Management CRUD API (Only ADMIN) ---
    @GetMapping("/users")
    public ResponseEntity<?> getAllUsers(HttpSession session) {
        if (!checkRole(session, List.of("ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }
        List<User> users = userRepository.findAll();
        // Clear passwords in payload
        for (User u : users) {
            u.setPassword(null);
        }
        return ResponseEntity.ok(users);
    }

    @PostMapping("/users")
    public ResponseEntity<?> createUser(@RequestBody User user, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        if (userRepository.findByUsername(user.getUsername()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Tên đăng nhập đã tồn tại."));
        }
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Email đã tồn tại."));
        }

        user.setPassword(PasswordUtils.hash(user.getPassword()));
        User saved = userRepository.save(user);
        saved.setPassword(null);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/users/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Integer id, @RequestBody User updates, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        Optional<User> userOpt = userRepository.findById(id);
        if (userOpt.isPresent()) {
            User existing = userOpt.get();
            
            if (!existing.getEmail().equalsIgnoreCase(updates.getEmail())) {
                if (userRepository.findByEmail(updates.getEmail()).isPresent()) {
                    return ResponseEntity.badRequest().body(Map.of("message", "Email đã tồn tại."));
                }
            }

            existing.setFullName(updates.getFullName());
            existing.setEmail(updates.getEmail());
            existing.setPhone(updates.getPhone());
            existing.setAddress(updates.getAddress());
            existing.setRole(updates.getRole());
            existing.setStatus(updates.getStatus());

            if (updates.getPassword() != null && !updates.getPassword().trim().isEmpty()) {
                existing.setPassword(PasswordUtils.hash(updates.getPassword()));
            }

            User saved = userRepository.save(existing);
            saved.setPassword(null);
            return ResponseEntity.ok(saved);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy tài khoản."));
    }

    // --- Promotion Management CRUD API (Only ADMIN) ---
    @GetMapping("/promotions")
    public ResponseEntity<?> getAllPromotions(HttpSession session) {
        if (!checkRole(session, List.of("ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }
        return ResponseEntity.ok(promotionRepository.findAll());
    }

    @PostMapping("/promotions")
    public ResponseEntity<?> createPromotion(@RequestBody Promotion promotion, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }
        if (promotionRepository.findByCode(promotion.getCode()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Mã giảm giá đã tồn tại."));
        }
        Promotion saved = promotionRepository.save(promotion);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/promotions/{id}")
    public ResponseEntity<?> updatePromotion(@PathVariable Integer id, @RequestBody Promotion promoUpdates, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        Optional<Promotion> promoOpt = promotionRepository.findById(id);
        if (promoOpt.isPresent()) {
            Promotion existing = promoOpt.get();
            existing.setCode(promoUpdates.getCode());
            existing.setDiscountType(promoUpdates.getDiscountType());
            existing.setDiscountValue(promoUpdates.getDiscountValue());
            existing.setMinOrderValue(promoUpdates.getMinOrderValue());
            existing.setMaxDiscount(promoUpdates.getMaxDiscount());
            existing.setStartDate(promoUpdates.getStartDate());
            existing.setEndDate(promoUpdates.getEndDate());
            existing.setActive(promoUpdates.getActive());

            Promotion saved = promotionRepository.save(existing);
            return ResponseEntity.ok(saved);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy khuyến mãi."));
    }

    @DeleteMapping("/promotions/{id}")
    public ResponseEntity<?> deletePromotion(@PathVariable Integer id, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }

        if (promotionRepository.existsById(id)) {
            promotionRepository.deleteById(id);
            return ResponseEntity.ok(Map.of("message", "Xóa khuyến mãi thành công."));
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy khuyến mãi."));
    }

    // --- Banner Management API (ADMIN & EMPLOYEE) ---
    @GetMapping("/banners")
    public ResponseEntity<?> getAllBanners(HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }
        return ResponseEntity.ok(bannerRepository.findAll());
    }

    @PostMapping("/banners")
    public ResponseEntity<?> createBanner(@RequestBody Banner banner, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }
        if (banner.getActive() == null) banner.setActive(true);
        if (banner.getDisplayOrder() == null) banner.setDisplayOrder(0);
        Banner saved = bannerRepository.save(banner);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/banners/{id}")
    public ResponseEntity<?> updateBanner(@PathVariable("id") Integer id, @RequestBody Banner bannerUpdates, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }
        Optional<Banner> bannerOpt = bannerRepository.findById(id);
        if (bannerOpt.isPresent()) {
            Banner existing = bannerOpt.get();
            existing.setTitle(bannerUpdates.getTitle());
            existing.setImageUrl(bannerUpdates.getImageUrl());
            existing.setLinkUrl(bannerUpdates.getLinkUrl());
            existing.setActive(bannerUpdates.getActive());
            existing.setDisplayOrder(bannerUpdates.getDisplayOrder());
            Banner saved = bannerRepository.save(existing);
            return ResponseEntity.ok(saved);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy Banner."));
    }

    @DeleteMapping("/banners/{id}")
    public ResponseEntity<?> deleteBanner(@PathVariable("id") Integer id, HttpSession session) {
        if (!checkRole(session, List.of("ADMIN", "EMPLOYEE"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Không có quyền thực hiện."));
        }
        if (bannerRepository.existsById(id)) {
            bannerRepository.deleteById(id);
            return ResponseEntity.ok(Map.of("message", "Xóa Banner thành công."));
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy Banner."));
    }
}

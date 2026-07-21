package com.poly.controller;

import com.poly.entity.*;
import com.poly.repository.*;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private ProductImageRepository productImageRepository;

    @Autowired
    private ProductVariantRepository productVariantRepository;

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public List<Product> getProducts(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "categoryId", required = false) Integer categoryId,
            @RequestParam(name = "minPrice", required = false) BigDecimal minPrice,
            @RequestParam(name = "maxPrice", required = false) BigDecimal maxPrice,
            @RequestParam(name = "brand", required = false) String brand,
            @RequestParam(name = "status", defaultValue = "ACTIVE") String status
    ) {
        // Find all matching products
        List<Product> products = productRepository.searchProducts(
                keyword, categoryId, minPrice, maxPrice, brand, "ALL".equalsIgnoreCase(status) ? null : status
        );

        // Populate categoryName for each product
        for (Product p : products) {
            if (p.getCategoryId() != null) {
                categoryRepository.findById(p.getCategoryId()).ifPresent(c -> p.setCategoryName(c.getName()));
            }
        }
        return products;
    }

    @GetMapping("/featured")
    public List<Product> getFeaturedProducts() {
        List<Product> featured = productRepository.findTop8ByStatusOrderByRatingDescCreatedAtDesc("ACTIVE");
        for (Product p : featured) {
            if (p.getCategoryId() != null) {
                categoryRepository.findById(p.getCategoryId()).ifPresent(c -> p.setCategoryName(c.getName()));
            }
        }
        return featured;
    }

    @GetMapping("/brands")
    public List<String> getUniqueBrands() {
        return productRepository.findUniqueBrands();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getProductDetail(@PathVariable("id") Integer id) {
        Optional<Product> productOpt = productRepository.findById(id);
        if (productOpt.isPresent()) {
            Product p = productOpt.get();
            if (p.getCategoryId() != null) {
                categoryRepository.findById(p.getCategoryId()).ifPresent(c -> p.setCategoryName(c.getName()));
            }

            List<ProductImage> images = productImageRepository.findByProductId(id);
            List<ProductVariant> variants = productVariantRepository.findByProductId(id);
            List<Review> reviews = reviewRepository.findByProductIdOrderByCreatedAtDesc(id);

            // Populate reviewers' full names
            for (Review r : reviews) {
                if (r.getUserId() != null) {
                    userRepository.findById(r.getUserId()).ifPresent(u -> r.setComment(r.getComment() + " - " + u.getFullName())); 
                    // Or we can construct a composite review payload, but let's send a map for response representation:
                }
            }

            Map<String, Object> details = new HashMap<>();
            details.put("product", p);
            details.put("images", images);
            details.put("variants", variants);
            details.put("reviews", reviews);

            return ResponseEntity.ok(details);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Sản phẩm không tồn tại."));
    }

    @PostMapping("/{id}/reviews")
    public ResponseEntity<?> addProductReview(
            @PathVariable("id") Integer id,
            @RequestBody Review reviewRequest,
            HttpSession session
    ) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Vui lòng đăng nhập để đánh giá sản phẩm."));
        }

        Optional<Product> productOpt = productRepository.findById(id);
        if (productOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Sản phẩm không tồn tại."));
        }

        Review review = new Review();
        review.setUserId(currentUser.getId());
        review.setProductId(id);
        review.setRating(reviewRequest.getRating());
        review.setComment(reviewRequest.getComment());
        
        Review saved = reviewRepository.save(review);
        
        // Update product average rating
        List<Review> reviews = reviewRepository.findByProductIdOrderByCreatedAtDesc(id);
        double avgRating = reviews.stream().mapToInt(Review::getRating).average().orElse(5.0);
        Product p = productOpt.get();
        p.setRating(BigDecimal.valueOf(avgRating));
        productRepository.save(p);

        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }
}

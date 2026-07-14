package com.poly.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description")
    private String description;

    @Column(name = "price", nullable = false)
    private BigDecimal price;

    @Column(name = "original_price")
    private BigDecimal originalPrice;

    @Column(name = "rating")
    private BigDecimal rating;

    @Column(name = "brand")
    private String brand;

    @Column(name = "image_url", nullable = false)
    private String imageUrl;

    @Column(name = "category_id")
    private Integer categoryId;

    @Column(name = "status")
    private String status; // 'ACTIVE', 'INACTIVE'

    @Column(name = "created_at", insertable = false, updatable = false)
    private Timestamp createdAt;
    
    // Transient field for view convenience
    @Transient
    private String categoryName;
}

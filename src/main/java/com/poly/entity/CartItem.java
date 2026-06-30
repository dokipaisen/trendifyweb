package com.poly.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import javax.persistence.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "cart_items")
public class CartItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "product_id")
    private Integer productId;

    @Column(name = "variant_id")
    private Integer variantId;

    @Column(name = "quantity")
    private Integer quantity;

    // Transient fields for easy JSP rendering
    @Transient
    private String productName;
    
    @Transient
    private String productBrand;
    
    @Transient
    private String productImageUrl;
    
    @Transient
    private String size;
    
    @Transient
    private String color;
    
    @Transient
    private BigDecimal price;
    
    public BigDecimal getTotalPrice() {
        if (price == null) return BigDecimal.ZERO;
        return price.multiply(new BigDecimal(quantity));
    }
}

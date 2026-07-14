package com.poly.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "order_code", unique = true, nullable = false)
    private String orderCode;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(name = "phone", nullable = false)
    private String phone;

    @Column(name = "address", nullable = false)
    private String address;

    @Column(name = "notes")
    private String notes;

    @Column(name = "payment_method")
    private String paymentMethod; // 'COD', 'BANK_TRANSFER'

    @Column(name = "payment_status")
    private String paymentStatus; // 'UNPAID', 'PAID'

    @Column(name = "shipping_fee")
    private BigDecimal shippingFee;

    @Column(name = "discount_amount")
    private BigDecimal discountAmount;

    @Column(name = "total_amount", nullable = false)
    private BigDecimal totalAmount;

    @Column(name = "status")
    private String status; // 'PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPING', 'DELIVERED', 'CANCELLED'

    @Column(name = "employee_id")
    private Integer employeeId;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Timestamp createdAt;

    // Transient list of items
    @Transient
    private List<OrderItem> items;

    @Transient
    private String payUrl;
}

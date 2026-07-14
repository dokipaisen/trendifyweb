package com.poly.repository;

import com.poly.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Integer> {
    List<CartItem> findByUserId(Integer userId);
    Optional<CartItem> findByUserIdAndVariantId(Integer userId, Integer variantId);
    void deleteByUserIdAndVariantId(Integer userId, Integer variantId);
    void deleteByUserId(Integer userId);
}

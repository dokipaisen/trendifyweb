package com.poly.dao;

import com.poly.entity.CartItem;
import com.poly.utils.JpaUtils;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import java.util.ArrayList;
import java.util.List;

public class CartDao {

    public List<CartItem> findByUserId(Integer userId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            List<Object[]> results = em.createQuery(
                "SELECT c, p.name, p.brand, p.imageUrl, p.price, pv.size, pv.color " +
                "FROM CartItem c " +
                "JOIN Product p ON c.productId = p.id " +
                "JOIN ProductVariant pv ON c.variantId = pv.id " +
                "WHERE c.userId = :userId", Object[].class)
                .setParameter("userId", userId)
                .getResultList();
                
            List<CartItem> list = new ArrayList<>();
            for (Object[] row : results) {
                CartItem item = (CartItem) row[0];
                item.setProductName((String) row[1]);
                item.setProductBrand((String) row[2]);
                item.setProductImageUrl((String) row[3]);
                item.setPrice((java.math.BigDecimal) row[4]);
                item.setSize((String) row[5]);
                item.setColor((String) row[6]);
                list.add(item);
            }
            return list;
        } finally {
            em.close();
        }
    }

    public CartItem findByUserAndVariant(Integer userId, Integer variantId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.createQuery("SELECT c FROM CartItem c WHERE c.userId = :userId AND c.variantId = :variantId", CartItem.class)
                .setParameter("userId", userId)
                .setParameter("variantId", variantId)
                .getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public boolean addToCart(CartItem item) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            CartItem existing = null;
            try {
                existing = em.createQuery("SELECT c FROM CartItem c WHERE c.userId = :userId AND c.variantId = :variantId", CartItem.class)
                    .setParameter("userId", item.getUserId())
                    .setParameter("variantId", item.getVariantId())
                    .getSingleResult();
            } catch (NoResultException ignored) {}

            if (existing != null) {
                existing.setQuantity(existing.getQuantity() + item.getQuantity());
                em.merge(existing);
            } else {
                em.persist(item);
            }
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean updateQuantity(Integer userId, Integer variantId, Integer quantity) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            int updated = em.createQuery("UPDATE CartItem c SET c.quantity = :quantity WHERE c.userId = :userId AND c.variantId = :variantId")
                .setParameter("quantity", quantity)
                .setParameter("userId", userId)
                .setParameter("variantId", variantId)
                .executeUpdate();
            em.getTransaction().commit();
            return updated > 0;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean deleteItem(Integer userId, Integer variantId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            int deleted = em.createQuery("DELETE FROM CartItem c WHERE c.userId = :userId AND c.variantId = :variantId")
                .setParameter("userId", userId)
                .setParameter("variantId", variantId)
                .executeUpdate();
            em.getTransaction().commit();
            return deleted > 0;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean clearCart(Integer userId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery("DELETE FROM CartItem c WHERE c.userId = :userId")
                .setParameter("userId", userId)
                .executeUpdate();
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }
}

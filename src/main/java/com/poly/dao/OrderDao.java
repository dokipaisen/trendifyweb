package com.poly.dao;

import com.poly.entity.Order;
import com.poly.entity.OrderItem;
import com.poly.entity.ProductVariant;
import com.poly.utils.JpaUtils;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import java.util.ArrayList;
import java.util.List;

public class OrderDao {

    public List<Order> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<Order> query = em.createQuery("SELECT o FROM Order o ORDER BY o.createdAt DESC", Order.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public List<Order> findByUserId(Integer userId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<Order> query = em.createQuery(
                "SELECT o FROM Order o WHERE o.userId = :userId ORDER BY o.createdAt DESC", Order.class);
            query.setParameter("userId", userId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public Order findById(Integer id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            Order order = em.find(Order.class, id);
            if (order != null) {
                order.setItems(findItemsByOrderId(order.getId()));
            }
            return order;
        } finally {
            em.close();
        }
    }

    public Order findByOrderCode(String code) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            Order order = em.createQuery("SELECT o FROM Order o WHERE o.orderCode = :code", Order.class)
                .setParameter("code", code)
                .getSingleResult();
            if (order != null) {
                order.setItems(findItemsByOrderId(order.getId()));
            }
            return order;
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public boolean createOrder(Order order, List<OrderItem> items) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();

            // 1. Persist Order
            em.persist(order);

            // 2. Persist Items & Deduct Stock
            for (OrderItem item : items) {
                item.setOrderId(order.getId());
                em.persist(item);

                // Deduct stock if variant exists
                if (item.getVariantId() != null) {
                    ProductVariant pv = em.find(ProductVariant.class, item.getVariantId());
                    if (pv == null || pv.getStock() < item.getQuantity()) {
                        // Out of stock or invalid variant ID
                        throw new RuntimeException("Out of stock or variant not found for ID: " + item.getVariantId());
                    }
                    pv.setStock(pv.getStock() - item.getQuantity());
                    em.merge(pv);
                }
            }

            // 3. Clear Cart if user logged in
            if (order.getUserId() != null) {
                em.createQuery("DELETE FROM CartItem c WHERE c.userId = :userId")
                  .setParameter("userId", order.getUserId())
                  .executeUpdate();
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

    public boolean updateStatus(Integer orderId, String status, String paymentStatus) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            Order order = em.find(Order.class, orderId);
            if (order != null) {
                order.setStatus(status);
                order.setPaymentStatus(paymentStatus);
                em.merge(order);
                em.getTransaction().commit();
                return true;
            }
            return false;
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

    public List<OrderItem> findItemsByOrderId(Integer orderId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            List<Object[]> results = em.createQuery(
                "SELECT oi, p.imageUrl FROM OrderItem oi LEFT JOIN Product p ON oi.productId = p.id " +
                "WHERE oi.orderId = :orderId", Object[].class)
                .setParameter("orderId", orderId)
                .getResultList();

            List<OrderItem> list = new ArrayList<>();
            for (Object[] row : results) {
                OrderItem item = (OrderItem) row[0];
                item.setProductImageUrl((String) row[1]);
                list.add(item);
            }
            return list;
        } finally {
            em.close();
        }
    }
}

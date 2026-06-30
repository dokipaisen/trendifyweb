package com.poly.dao;

import com.poly.entity.Review;
import com.poly.utils.JpaUtils;
import javax.persistence.EntityManager;
import java.util.ArrayList;
import java.util.List;

public class ReviewDao {

    public List<Review> findByProductId(Integer productId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            List<Object[]> results = em.createQuery(
                "SELECT r, u.fullName FROM Review r JOIN User u ON r.userId = u.id " +
                "WHERE r.productId = :productId ORDER BY r.createdAt DESC", Object[].class)
                .setParameter("productId", productId)
                .getResultList();
                
            List<Review> list = new ArrayList<>();
            for (Object[] row : results) {
                Review r = (Review) row[0];
                String fullName = (String) row[1];
                r.setUserFullName(fullName);
                list.add(r);
            }
            return list;
        } finally {
            em.close();
        }
    }

    public boolean create(Review review) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(review);
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

package com.poly.dao;

import com.poly.entity.ProductVariant;
import com.poly.utils.JpaUtils;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import java.util.List;

public class ProductVariantDao {

    public List<ProductVariant> findByProductId(Integer productId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<ProductVariant> query = em.createQuery(
                "SELECT pv FROM ProductVariant pv WHERE pv.productId = :productId ORDER BY pv.size, pv.color", ProductVariant.class);
            query.setParameter("productId", productId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public ProductVariant findById(Integer id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.find(ProductVariant.class, id);
        } finally {
            em.close();
        }
    }

    public boolean create(ProductVariant pv) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(pv);
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

    public boolean update(ProductVariant pv) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(pv);
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

    public boolean updateStock(Integer id, Integer newStock) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            ProductVariant pv = em.find(ProductVariant.class, id);
            if (pv != null) {
                pv.setStock(newStock);
                em.merge(pv);
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

    public boolean delete(Integer id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            ProductVariant pv = em.find(ProductVariant.class, id);
            if (pv != null) {
                em.remove(pv);
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

    public boolean deleteByProductId(Integer productId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery("DELETE FROM ProductVariant pv WHERE pv.productId = :productId")
              .setParameter("productId", productId)
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

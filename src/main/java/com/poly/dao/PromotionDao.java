package com.poly.dao;

import com.poly.entity.Promotion;
import com.poly.utils.JpaUtils;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import java.util.List;

public class PromotionDao {

    public Promotion findByCode(String code) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<Promotion> query = em.createQuery(
                "SELECT p FROM Promotion p WHERE p.code = :code AND p.active = true " +
                "AND (p.startDate IS NULL OR p.startDate <= CURRENT_TIMESTAMP) " +
                "AND (p.endDate IS NULL OR p.endDate >= CURRENT_TIMESTAMP)", Promotion.class);
            query.setParameter("code", code);
            return query.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public List<Promotion> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<Promotion> query = em.createQuery("SELECT p FROM Promotion p ORDER BY p.id DESC", Promotion.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public boolean create(Promotion p) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            if (p.getActive() == null) {
                p.setActive(true);
            }
            em.persist(p);
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

    public boolean update(Promotion p) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(p);
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

    public boolean delete(Integer id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            Promotion p = em.find(Promotion.class, id);
            if (p != null) {
                em.remove(p);
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
}

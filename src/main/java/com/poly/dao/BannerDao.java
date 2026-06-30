package com.poly.dao;

import com.poly.entity.Banner;
import com.poly.utils.JpaUtils;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import java.util.List;

public class BannerDao {

    public List<Banner> findActive() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<Banner> query = em.createQuery("SELECT b FROM Banner b WHERE b.active = true ORDER BY b.displayOrder ASC", Banner.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public List<Banner> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<Banner> query = em.createQuery("SELECT b FROM Banner b ORDER BY b.displayOrder ASC", Banner.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public boolean create(Banner b) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(b);
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

    public boolean update(Banner b) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(b);
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
            Banner b = em.find(Banner.class, id);
            if (b != null) {
                em.remove(b);
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

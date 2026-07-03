package com.poly.dao;

import com.poly.entity.User;
import com.poly.utils.JpaUtils;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import java.util.List;

public class UserDao {

    public User findByUsername(String username) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery("SELECT u FROM User u WHERE u.username = :username", User.class);
            query.setParameter("username", username);
            return query.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public User findByEmail(String email) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class);
            query.setParameter("email", email);
            return query.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public boolean create(User user) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            if (user.getRole() == null) {
                user.setRole("CUSTOMER");
            }
            if (user.getStatus() == null) {
                user.setStatus("ACTIVE");
            }
            em.persist(user);
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

    public boolean update(User user) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            User existing = em.find(User.class, user.getId());
            if (existing != null) {
                existing.setFullName(user.getFullName());
                existing.setEmail(user.getEmail());
                existing.setPhone(user.getPhone());
                existing.setAddress(user.getAddress());
                existing.setRole(user.getRole());
                existing.setStatus(user.getStatus());
                em.merge(existing);
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

    public boolean updatePassword(Integer userId, String newPassword) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            User user = em.find(User.class, userId);
            if (user != null) {
                user.setPassword(newPassword);
                em.merge(user);
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

    public List<User> findStaffs() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE u.role = 'ADMIN' OR u.role = 'EMPLOYEE' ORDER BY u.fullName ASC", User.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public List<User> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery("SELECT u FROM User u ORDER BY u.createdAt DESC", User.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
}

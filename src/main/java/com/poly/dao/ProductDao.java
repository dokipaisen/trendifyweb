package com.poly.dao;

import com.poly.entity.Product;
import com.poly.entity.ProductImage;
import com.poly.utils.JpaUtils;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import java.util.ArrayList;
import java.util.List;

public class ProductDao {

    public List<Product> findAll(String keyword, Integer categoryId, Double minPrice, Double maxPrice, String brand, String status) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT p, c.name FROM Product p LEFT JOIN Category c ON p.categoryId = c.id WHERE 1=1");
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                jpql.append(" AND (p.name LIKE :keyword OR p.brand LIKE :keyword)");
            }
            if (categoryId != null && categoryId > 0) {
                jpql.append(" AND p.categoryId = :categoryId");
            }
            if (minPrice != null) {
                jpql.append(" AND p.price >= :minPrice");
            }
            if (maxPrice != null) {
                jpql.append(" AND p.price <= :maxPrice");
            }
            if (brand != null && !brand.trim().isEmpty()) {
                jpql.append(" AND p.brand = :brand");
            }
            if (status != null && !status.trim().isEmpty()) {
                if (!status.equalsIgnoreCase("ALL")) {
                    jpql.append(" AND p.status = :status");
                }
            } else {
                jpql.append(" AND p.status = 'ACTIVE'");
            }
            jpql.append(" ORDER BY p.createdAt DESC");

            TypedQuery<Object[]> query = em.createQuery(jpql.toString(), Object[].class);

            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("keyword", "%" + keyword.trim() + "%");
            }
            if (categoryId != null && categoryId > 0) {
                query.setParameter("categoryId", categoryId);
            }
            if (minPrice != null) {
                query.setParameter("minPrice", new java.math.BigDecimal(minPrice));
            }
            if (maxPrice != null) {
                query.setParameter("maxPrice", new java.math.BigDecimal(maxPrice));
            }
            if (brand != null && !brand.trim().isEmpty()) {
                query.setParameter("brand", brand.trim());
            }
            if (status != null && !status.trim().isEmpty()) {
                if (!status.equalsIgnoreCase("ALL")) {
                    query.setParameter("status", status.trim());
                }
            }

            List<Object[]> results = query.getResultList();
            List<Product> list = new ArrayList<>();
            for (Object[] row : results) {
                Product p = (Product) row[0];
                String catName = (String) row[1];
                p.setCategoryName(catName);
                list.add(p);
            }
            return list;
        } finally {
            em.close();
        }
    }

    public Product findById(Integer id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            List<Object[]> results = em.createQuery(
                "SELECT p, c.name FROM Product p LEFT JOIN Category c ON p.categoryId = c.id WHERE p.id = :id", Object[].class)
                .setParameter("id", id)
                .getResultList();
            if (!results.isEmpty()) {
                Product p = (Product) results.get(0)[0];
                String catName = (String) results.get(0)[1];
                p.setCategoryName(catName);
                return p;
            }
            return null;
        } finally {
            em.close();
        }
    }

    public List<Product> findFeatured() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            List<Object[]> results = em.createQuery(
                "SELECT p, c.name FROM Product p LEFT JOIN Category c ON p.categoryId = c.id " +
                "WHERE p.status = 'ACTIVE' ORDER BY p.rating DESC, p.createdAt DESC", Object[].class)
                .setMaxResults(8)
                .getResultList();
            List<Product> list = new ArrayList<>();
            for (Object[] row : results) {
                Product p = (Product) row[0];
                String catName = (String) row[1];
                p.setCategoryName(catName);
                list.add(p);
            }
            return list;
        } finally {
            em.close();
        }
    }

    public boolean create(Product p) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            if (p.getRating() == null) {
                p.setRating(new java.math.BigDecimal("5.0"));
            }
            if (p.getStatus() == null) {
                p.setStatus("ACTIVE");
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

    public boolean update(Product p) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            Product existing = em.find(Product.class, p.getId());
            if (existing != null) {
                existing.setName(p.getName());
                existing.setDescription(p.getDescription());
                existing.setPrice(p.getPrice());
                existing.setOriginalPrice(p.getOriginalPrice());
                existing.setBrand(p.getBrand());
                existing.setImageUrl(p.getImageUrl());
                existing.setCategoryId(p.getCategoryId());
                existing.setStatus(p.getStatus());
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

    public boolean delete(Integer id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            Product p = em.find(Product.class, id);
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

    // Secondary images management
    public List<ProductImage> getProductImages(Integer productId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<ProductImage> query = em.createQuery(
                "SELECT pi FROM ProductImage pi WHERE pi.productId = :productId", ProductImage.class);
            query.setParameter("productId", productId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public boolean addProductImage(Integer productId, String imageUrl) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            ProductImage img = new ProductImage();
            img.setProductId(productId);
            img.setImageUrl(imageUrl);
            em.persist(img);
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

    public boolean deleteProductImages(Integer productId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery("DELETE FROM ProductImage pi WHERE pi.productId = :productId")
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

    public List<String> findUniqueBrands() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<String> query = em.createQuery(
                "SELECT DISTINCT p.brand FROM Product p WHERE p.brand IS NOT NULL AND p.brand <> '' AND p.status = 'ACTIVE'", String.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
}

package com.poly.utils;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

public class JpaUtils {
    private static EntityManagerFactory factory;

    static {
        try {
            factory = Persistence.createEntityManagerFactory("ClothingStorePU");
            
            // Run automatic database updates (Alter orders table to add employee_id if it's missing)
            EntityManager em = factory.createEntityManager();
            try {
                em.getTransaction().begin();
                em.createNativeQuery("ALTER TABLE orders ADD employee_id INT FOREIGN KEY REFERENCES users(id) ON DELETE NO ACTION").executeUpdate();
                em.getTransaction().commit();
                System.out.println("Auto-migration: Added employee_id column to orders table successfully!");
            } catch (Exception ex) {
                // Column might already exist or DB connection error (ignored for migration robustness)
                if (em.getTransaction().isActive()) {
                    em.getTransaction().rollback();
                }
            } finally {
                em.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("EntityManagerFactory creation failed!");
        }
    }

    public static EntityManager getEntityManager() {
        if (factory == null || !factory.isOpen()) {
            factory = Persistence.createEntityManagerFactory("ClothingStorePU");
        }
        return factory.createEntityManager();
    }

    public static void shutdown() {
        if (factory != null && factory.isOpen()) {
            factory.close();
        }
    }
}

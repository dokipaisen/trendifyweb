package com.poly.utils;

import com.poly.entity.Product;
import javax.persistence.EntityManager;
import java.util.HashMap;
import java.util.Map;

public class DatabaseSeeder {
    public static void main(String[] args) {
        Map<Integer, String> imageMap = new HashMap<>();
        imageMap.put(1, "https://images.pexels.com/photos/2205839/pexels-photo-2205839.jpeg?auto=compress&cs=tinysrgb&w=600"); // Áo thun Cotton Basic (màu xanh lá)
        imageMap.put(2, "https://images.pexels.com/photos/2220315/pexels-photo-2220315.jpeg?auto=compress&cs=tinysrgb&w=600"); // Sơ mi Oxford Dài Tay (màu xanh dương)
        imageMap.put(3, "https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg?auto=compress&cs=tinysrgb&w=600"); // Quần jean Slim Fit Denim (màu xanh chàm)
        imageMap.put(4, "https://images.pexels.com/photos/1525489/pexels-photo-1525489.jpeg?auto=compress&cs=tinysrgb&w=600"); // Áo khoác Gió Thể Thao Waterproof (màu vàng dã ngoại)
        imageMap.put(5, "https://images.pexels.com/photos/2235071/pexels-photo-2235071.jpeg?auto=compress&cs=tinysrgb&w=600"); // Váy đầm Hoa Nhí Dáng Xoè Nữ
        imageMap.put(6, "https://images.pexels.com/photos/1566412/pexels-photo-1566412.jpeg?auto=compress&cs=tinysrgb&w=600"); // Áo thun Nam Cổ Tròn Basic Cotton (màu đỏ mận)
        imageMap.put(7, "https://images.pexels.com/photos/1484807/pexels-photo-1484807.jpeg?auto=compress&cs=tinysrgb&w=600"); // Áo thun Polo Premium Trẻ Trung (màu đỏ đô)
        imageMap.put(8, "https://images.pexels.com/photos/3755706/pexels-photo-3755706.jpeg?auto=compress&cs=tinysrgb&w=600"); // Áo sơ mi Linen Cổ Tàu (màu kem cát)
        imageMap.put(9, "https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?auto=compress&cs=tinysrgb&w=600"); // Áo sơ mi Flannel Kẻ Caro (màu đỏ đen)
        imageMap.put(10, "https://images.pexels.com/photos/1598507/pexels-photo-1598507.jpeg?auto=compress&cs=tinysrgb&w=600"); // Quần jean Nam Regular Fit (màu xanh denim cổ điển)
        imageMap.put(11, "https://images.pexels.com/photos/1598505/pexels-photo-1598505.jpeg?auto=compress&cs=tinysrgb&w=600"); // Quần jean Nam Rách Gối Cá Tính
        imageMap.put(12, "https://images.pexels.com/photos/1631181/pexels-photo-1631181.jpeg?auto=compress&cs=tinysrgb&w=600"); // Áo khoác Bomber Da Lộn (màu nâu da bò)
        imageMap.put(13, "https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg?auto=compress&cs=tinysrgb&w=600"); // Áo khoác Hoodie Nữ Bông (màu cam)
        imageMap.put(14, "https://images.pexels.com/photos/3387577/pexels-photo-3387577.jpeg?auto=compress&cs=tinysrgb&w=600"); // Váy đầm Maxi Đi Biển Voan Tơ (màu vàng nhạt)
        imageMap.put(15, "https://images.pexels.com/photos/2065195/pexels-photo-2065195.jpeg?auto=compress&cs=tinysrgb&w=600"); // Váy đầm Body Cổ Vuông (màu đen)

        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            for (Map.Entry<Integer, String> entry : imageMap.entrySet()) {
                Product p = em.find(Product.class, entry.getKey());
                if (p != null) {
                    p.setImageUrl(entry.getValue());
                    em.merge(p);
                    System.out.println("Updated image for product ID " + entry.getKey());
                }
            }
            em.getTransaction().commit();
            System.out.println("All product images updated successfully!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
        } finally {
            em.close();
            JpaUtils.shutdown();
        }
    }
}

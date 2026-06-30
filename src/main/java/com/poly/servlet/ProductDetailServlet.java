package com.poly.servlet;

import com.poly.dao.ProductDao;
import com.poly.dao.ProductVariantDao;
import com.poly.dao.ReviewDao;
import com.poly.entity.Product;
import com.poly.entity.ProductImage;
import com.poly.entity.ProductVariant;
import com.poly.entity.Review;
import com.poly.entity.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/product/detail")
public class ProductDetailServlet extends HttpServlet {
    private final ProductDao productDao = new ProductDao();
    private final ProductVariantDao variantDao = new ProductVariantDao();
    private final ReviewDao reviewDao = new ReviewDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Product product = productDao.findById(id);
            if (product == null) {
                resp.sendRedirect(req.getContextPath() + "/shop");
                return;
            }

            List<ProductImage> images = productDao.getProductImages(id);
            List<ProductVariant> variants = variantDao.findByProductId(id);
            List<Review> reviews = reviewDao.findByProductId(id);

            req.setAttribute("product", product);
            req.setAttribute("images", images);
            req.setAttribute("variants", variants);
            req.setAttribute("reviews", reviews);

            req.getRequestDispatcher("/views/product-detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/shop");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            session.setAttribute("authError", "Vui lòng đăng nhập để đánh giá sản phẩm.");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String productIdStr = req.getParameter("productId");
        String ratingStr = req.getParameter("rating");
        String comment = req.getParameter("comment");

        try {
            int productId = Integer.parseInt(productIdStr);
            int rating = Integer.parseInt(ratingStr);

            Review review = new Review();
            review.setUserId(currentUser.getId());
            review.setProductId(productId);
            review.setRating(rating);
            review.setComment(comment);

            reviewDao.create(review);
            
            // Re-calculate average rating for product and update
            List<Review> list = reviewDao.findByProductId(productId);
            double sum = 0;
            for (Review r : list) {
                sum += r.getRating();
            }
            double avg = list.isEmpty() ? 5.0 : sum / list.size();
            Product p = productDao.findById(productId);
            if (p != null) {
                p.setRating(new java.math.BigDecimal(String.format("%.2f", avg)));
                productDao.update(p);
            }

            session.setAttribute("cartSuccess", "Đã gửi nhận xét đánh giá của bạn.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("cartError", "Có lỗi xảy ra khi gửi đánh giá.");
        }

        resp.sendRedirect(req.getContextPath() + "/product/detail?id=" + productIdStr);
    }
}

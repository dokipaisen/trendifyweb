package com.poly.servlet;

import com.poly.dao.BannerDao;
import com.poly.dao.ProductDao;
import com.poly.entity.Banner;
import com.poly.entity.Product;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {
    private final BannerDao bannerDao = new BannerDao();
    private final ProductDao productDao = new ProductDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Banner> banners = bannerDao.findActive();
        List<Product> featured = productDao.findFeatured();

        req.setAttribute("banners", banners);
        req.setAttribute("featuredProducts", featured);

        req.getRequestDispatcher("/views/home.jsp").forward(req, resp);
    }
}

package com.poly.servlet;

import com.poly.dao.CategoryDao;
import com.poly.dao.ProductDao;
import com.poly.entity.Category;
import com.poly.entity.Product;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/shop")
public class ShopServlet extends HttpServlet {
    private final ProductDao productDao = new ProductDao();
    private final CategoryDao categoryDao = new CategoryDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String categoryIdStr = req.getParameter("categoryId");
        String minPriceStr = req.getParameter("minPrice");
        String maxPriceStr = req.getParameter("maxPrice");
        String brand = req.getParameter("brand");

        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (NumberFormatException ignored) {}
        }

        Double minPrice = null;
        if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
            try {
                minPrice = Double.parseDouble(minPriceStr);
            } catch (NumberFormatException ignored) {}
        }

        Double maxPrice = null;
        if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
            try {
                maxPrice = Double.parseDouble(maxPriceStr);
            } catch (NumberFormatException ignored) {}
        }

        List<Product> products = productDao.findAll(keyword, categoryId, minPrice, maxPrice, brand, "ACTIVE");
        List<Category> categories = categoryDao.findAll();
        List<String> brands = productDao.findUniqueBrands();

        req.setAttribute("products", products);
        req.setAttribute("categories", categories);
        req.setAttribute("brands", brands);

        req.getRequestDispatcher("/views/shop.jsp").forward(req, resp);
    }
}

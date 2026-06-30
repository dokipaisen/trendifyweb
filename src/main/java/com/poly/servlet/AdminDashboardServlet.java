package com.poly.servlet;

import com.poly.dao.OrderDao;
import com.poly.dao.ProductDao;
import com.poly.dao.UserDao;
import com.poly.entity.Order;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private final OrderDao orderDao = new OrderDao();
    private final ProductDao productDao = new ProductDao();
    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Order> allOrders = orderDao.findAll();
        
        BigDecimal totalRevenue = BigDecimal.ZERO;
        int totalOrdersCount = allOrders.size();
        
        for (Order o : allOrders) {
            if (!"CANCELLED".equals(o.getStatus())) {
                totalRevenue = totalRevenue.add(o.getTotalAmount());
            }
        }

        int totalProducts = productDao.findAll(null, null, null, null, null, "ALL").size();
        int totalUsers = userDao.findAll().size();

        // Slice first 8 orders for SVG chart
        List<Order> chartOrders = new ArrayList<>();
        double maxOrderAmount = 10000.0; // Avoid divide by zero
        
        int limit = Math.min(8, allOrders.size());
        for (int i = 0; i < limit; i++) {
            Order o = allOrders.get(i);
            chartOrders.add(o);
            if (o.getTotalAmount().doubleValue() > maxOrderAmount) {
                maxOrderAmount = o.getTotalAmount().doubleValue();
            }
        }

        // Slice first 10 orders for Recent List
        List<Order> recentOrders = new ArrayList<>();
        int limitList = Math.min(10, allOrders.size());
        for (int i = 0; i < limitList; i++) {
            recentOrders.add(allOrders.get(i));
        }

        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("totalOrders", totalOrdersCount);
        req.setAttribute("totalProducts", totalProducts);
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("chartOrders", chartOrders);
        req.setAttribute("maxOrderAmount", maxOrderAmount);
        req.setAttribute("recentOrdersList", recentOrders);

        req.getRequestDispatcher("/views/admin/dashboard.jsp").forward(req, resp);
    }
}

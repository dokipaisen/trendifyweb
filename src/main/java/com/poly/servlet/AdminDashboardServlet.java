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
        // 1. Get filter parameters
        String empIdStr = req.getParameter("employeeId");
        String startDate = req.getParameter("startDate");
        String endDate = req.getParameter("endDate");
        String monthStr = req.getParameter("month");
        String yearStr = req.getParameter("year");

        Integer employeeId = null;
        if (empIdStr != null && !empIdStr.trim().isEmpty()) {
            try { employeeId = Integer.parseInt(empIdStr); } catch (Exception ignored) {}
        }
        Integer month = null;
        if (monthStr != null && !monthStr.trim().isEmpty()) {
            try { month = Integer.parseInt(monthStr); } catch (Exception ignored) {}
        }
        Integer year = null;
        if (yearStr != null && !yearStr.trim().isEmpty()) {
            try { year = Integer.parseInt(yearStr); } catch (Exception ignored) {}
        }
        if (month != null && year == null) {
            year = java.time.LocalDate.now().getYear();
        }

        // 2. Fetch data from DAO
        List<com.poly.entity.User> staffList = userDao.findStaffs();
        Object[] stats = orderDao.getStatistics(employeeId, startDate, endDate, month, year);
        BigDecimal totalRevenue = (BigDecimal) stats[0];
        long totalOrdersCount = (Long) stats[1];

        int totalProducts = productDao.findAll(null, null, null, null, null, "ALL").size();
        int totalUsers = userDao.findAll().size();

        List<Order> filteredOrders = orderDao.findFilteredOrders(employeeId, startDate, endDate, month, year);
        List<Object[]> employeeRankings = orderDao.getRevenueByEmployee(startDate, endDate, month, year);

        // Slice first 8 orders for SVG chart representing filtered revenue
        List<Order> chartOrders = new ArrayList<>();
        double maxOrderAmount = 10000.0; // Avoid divide by zero
        int limit = Math.min(8, filteredOrders.size());
        for (int i = 0; i < limit; i++) {
            Order o = filteredOrders.get(i);
            chartOrders.add(o);
            if (o.getTotalAmount().doubleValue() > maxOrderAmount) {
                maxOrderAmount = o.getTotalAmount().doubleValue();
            }
        }

        // Slice first 10 orders for Recent List (representing filtered list)
        List<Order> recentOrders = new ArrayList<>();
        int limitList = Math.min(10, filteredOrders.size());
        for (int i = 0; i < limitList; i++) {
            recentOrders.add(filteredOrders.get(i));
        }

        // 3. Set request attributes
        req.setAttribute("staffList", staffList);
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("totalOrders", totalOrdersCount);
        req.setAttribute("totalProducts", totalProducts);
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("chartOrders", chartOrders);
        req.setAttribute("maxOrderAmount", maxOrderAmount);
        req.setAttribute("recentOrdersList", recentOrders);
        req.setAttribute("employeeRankings", employeeRankings);

        // Keep filter values on UI
        req.setAttribute("selectedEmployeeId", employeeId);
        req.setAttribute("selectedStartDate", startDate);
        req.setAttribute("selectedEndDate", endDate);
        req.setAttribute("selectedMonth", month);
        req.setAttribute("selectedYear", year);

        req.getRequestDispatcher("/views/admin/dashboard.jsp").forward(req, resp);
    }
}

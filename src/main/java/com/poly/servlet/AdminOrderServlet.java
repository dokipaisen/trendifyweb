package com.poly.servlet;

import com.poly.dao.OrderDao;
import com.poly.entity.Order;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/orders")
public class AdminOrderServlet extends HttpServlet {
    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("detail".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    Order order = orderDao.findById(Integer.parseInt(idStr));
                    req.setAttribute("selectedOrder", order);
                } catch (NumberFormatException ignored) {}
            }
        }

        List<Order> orders = orderDao.findAll();
        req.setAttribute("orders", orders);

        req.getRequestDispatcher("/views/admin/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        if ("updateStatus".equals(action)) {
            String idStr = req.getParameter("id");
            String status = req.getParameter("status");
            String paymentStatus = req.getParameter("paymentStatus");

            try {
                int orderId = Integer.parseInt(idStr);
                boolean success = orderDao.updateStatus(orderId, status, paymentStatus);
                if (success) {
                    session.setAttribute("adminSuccess", "Cập nhật trạng thái đơn hàng thành công.");
                } else {
                    session.setAttribute("adminError", "Cập nhật trạng thái đơn hàng thất bại.");
                }
                resp.sendRedirect(req.getContextPath() + "/admin/orders?action=detail&id=" + idStr);
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/orders");
    }
}

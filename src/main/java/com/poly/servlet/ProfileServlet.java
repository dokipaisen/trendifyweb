package com.poly.servlet;

import com.poly.dao.OrderDao;
import com.poly.dao.UserDao;
import com.poly.entity.Order;
import com.poly.entity.User;
import com.poly.utils.PasswordUtils;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();
    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if ("orderDetail".equals(action)) {
            String code = req.getParameter("code");
            if (code != null) {
                Order order = orderDao.findByOrderCode(code);
                // Ensure users can only view their own orders
                if (order != null && currentUser.getId().equals(order.getUserId())) {
                    req.setAttribute("selectedOrder", order);
                }
            }
        }

        List<Order> orders = orderDao.findByUserId(currentUser.getId());
        req.setAttribute("orders", orders);

        req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if ("updateProfile".equals(action)) {
            String fullName = req.getParameter("fullName");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String address = req.getParameter("address");

            // Email check
            User otherUser = userDao.findByEmail(email);
            if (otherUser != null && !otherUser.getId().equals(currentUser.getId())) {
                session.setAttribute("profileError", "Email đã được sử dụng bởi một tài khoản khác.");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }

            currentUser.setFullName(fullName);
            currentUser.setEmail(email);
            currentUser.setPhone(phone);
            currentUser.setAddress(address);

            boolean success = userDao.update(currentUser);
            if (success) {
                session.setAttribute("currentUser", currentUser);
                session.setAttribute("profileSuccess", "Cập nhật hồ sơ cá nhân thành công.");
            } else {
                session.setAttribute("profileError", "Cập nhật hồ sơ cá nhân thất bại.");
            }

        } else if ("changePassword".equals(action)) {
            String oldPassword = req.getParameter("oldPassword");
            String newPassword = req.getParameter("newPassword");
            String confirmPassword = req.getParameter("confirmPassword");

            User currentDbUser = userDao.findByUsername(currentUser.getUsername());
            if (currentDbUser == null || !PasswordUtils.check(oldPassword, currentDbUser.getPassword())) {
                session.setAttribute("profileError", "Mật khẩu cũ không chính xác.");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }

            if (newPassword == null || newPassword.trim().isEmpty()) {
                session.setAttribute("profileError", "Mật khẩu mới không được để trống.");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                session.setAttribute("profileError", "Mật khẩu mới và mật khẩu xác nhận không khớp.");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }

            boolean success = userDao.updatePassword(currentUser.getId(), PasswordUtils.hash(newPassword));
            if (success) {
                session.setAttribute("profileSuccess", "Đổi mật khẩu thành công.");
            } else {
                session.setAttribute("profileError", "Có lỗi xảy ra, không thể thay đổi mật khẩu.");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}

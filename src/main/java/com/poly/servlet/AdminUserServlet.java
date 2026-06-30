package com.poly.servlet;

import com.poly.dao.UserDao;
import com.poly.entity.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<User> users = userDao.findAll();
        req.setAttribute("users", users);
        req.getRequestDispatcher("/views/admin/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        String role = req.getParameter("role");
        String status = req.getParameter("status");
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            int userId = Integer.parseInt(idStr);
            
            // Prevent changing own profile
            if (currentUser != null && currentUser.getId().equals(userId)) {
                session.setAttribute("adminError", "Bạn không được tự sửa thông tin phân quyền của chính mình.");
                resp.sendRedirect(req.getContextPath() + "/admin/users");
                return;
            }

            // Find user in db first
            List<User> list = userDao.findAll();
            User user = null;
            for (User u : list) {
                if (u.getId().equals(userId)) {
                    user = u;
                    break;
                }
            }

            if (user != null) {
                user.setRole(role);
                user.setStatus(status);
                boolean success = userDao.update(user);
                if (success) {
                    session.setAttribute("adminSuccess", "Cập nhật phân quyền người dùng thành công.");
                } else {
                    session.setAttribute("adminError", "Cập nhật người dùng thất bại.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("adminError", "Lỗi xử lý dữ liệu tài khoản.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}

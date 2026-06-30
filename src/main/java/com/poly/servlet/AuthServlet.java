package com.poly.servlet;

import com.poly.dao.CartDao;
import com.poly.dao.UserDao;
import com.poly.entity.CartItem;
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

@WebServlet(urlPatterns = {"/login", "/register"})
public class AuthServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();
    private final CartDao cartDao = new CartDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession();
        
        if ("/login".equals(path)) {
            String action = req.getParameter("action");
            if ("logout".equals(action)) {
                session.invalidate();
                HttpSession newSession = req.getSession(true);
                newSession.setAttribute("authSuccess", "Bạn đã đăng xuất thành công.");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            if (session.getAttribute("currentUser") != null) {
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
        } else if ("/register".equals(path)) {
            if (session.getAttribute("currentUser") != null) {
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession();

        if ("/login".equals(path)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String redirect = req.getParameter("redirect");

            User user = userDao.findByUsername(username);
            if (user != null && PasswordUtils.check(password, user.getPassword())) {
                if ("INACTIVE".equals(user.getStatus())) {
                    session.setAttribute("authError", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ.");
                    resp.sendRedirect(req.getContextPath() + "/login");
                    return;
                }

                session.setAttribute("currentUser", user);

                // Merge guest cart to db cart
                List<CartItem> guestCart = (List<CartItem>) session.getAttribute("guestCart");
                if (guestCart != null) {
                    for (CartItem item : guestCart) {
                        item.setUserId(user.getId());
                        cartDao.addToCart(item);
                    }
                    session.removeAttribute("guestCart");
                }

                // Set cart count
                int cartSize = cartDao.findByUserId(user.getId()).size();
                session.setAttribute("cartSize", cartSize);

                if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("/login") && !redirect.contains("/register")) {
                    resp.sendRedirect(redirect);
                } else {
                    if ("ADMIN".equals(user.getRole()) || "EMPLOYEE".equals(user.getRole())) {
                        resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/home");
                    }
                }
            } else {
                session.setAttribute("authError", "Tên đăng nhập hoặc mật khẩu không chính xác.");
                resp.sendRedirect(req.getContextPath() + "/login" + (redirect != null ? "?redirect=" + redirect : ""));
            }

        } else if ("/register".equals(path)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String fullName = req.getParameter("fullName");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String address = req.getParameter("address");

            // Validations
            if (userDao.findByUsername(username) != null) {
                session.setAttribute("authError", "Tên đăng nhập đã tồn tại trong hệ thống.");
                resp.sendRedirect(req.getContextPath() + "/register");
                return;
            }

            if (userDao.findByEmail(email) != null) {
                session.setAttribute("authError", "Email đã được sử dụng bởi một tài khoản khác.");
                resp.sendRedirect(req.getContextPath() + "/register");
                return;
            }

            User user = new User();
            user.setUsername(username);
            user.setPassword(PasswordUtils.hash(password));
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPhone(phone);
            user.setAddress(address);
            user.setRole("CUSTOMER");
            user.setStatus("ACTIVE");

            boolean success = userDao.create(user);
            if (success) {
                session.setAttribute("authSuccess", "Đăng ký tài khoản thành công! Vui lòng đăng nhập.");
                resp.sendRedirect(req.getContextPath() + "/login");
            } else {
                session.setAttribute("authError", "Có lỗi xảy ra trong quá trình tạo tài khoản.");
                resp.sendRedirect(req.getContextPath() + "/register");
            }
        }
    }
}

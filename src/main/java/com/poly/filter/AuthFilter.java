package com.poly.filter;

import com.poly.entity.User;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/checkout", "/profile"})
public class AuthFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession();
        
        User user = (User) session.getAttribute("currentUser");
        String uri = req.getRequestURI();

        if (user == null) {
            // Redirect to login if not logged in
            session.setAttribute("authError", "Vui lòng đăng nhập để truy cập trang này.");
            resp.sendRedirect(req.getContextPath() + "/login?redirect=" + uri);
            return;
        }

        // Protect admin routes
        if (uri.contains("/admin/")) {
            String role = user.getRole();
            if (!"ADMIN".equals(role) && !"EMPLOYEE".equals(role)) {
                // Not authorized
                session.setAttribute("authError", "Bạn không có quyền truy cập khu vực quản trị.");
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }

            // Restrict sensitive admin functions for EMPLOYEE role
            if ("EMPLOYEE".equals(role)) {
                if (uri.contains("/admin/users") || uri.contains("/admin/promotions") || uri.contains("/admin/dashboard")) {
                    session.setAttribute("adminError", "Tài khoản Nhân Viên không có quyền truy cập chức năng này.");
                    resp.sendRedirect(req.getContextPath() + "/admin/products");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}

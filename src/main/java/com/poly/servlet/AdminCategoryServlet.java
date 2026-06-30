package com.poly.servlet;

import com.poly.dao.CategoryDao;
import com.poly.entity.Category;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/categories")
public class AdminCategoryServlet extends HttpServlet {
    private final CategoryDao categoryDao = new CategoryDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        if ("edit".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    Category c = categoryDao.findById(Integer.parseInt(idStr));
                    req.setAttribute("editingCategory", c);
                } catch (NumberFormatException ignored) {}
            }
        } else if ("delete".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    categoryDao.delete(Integer.parseInt(idStr));
                    session.setAttribute("adminSuccess", "Đã xóa danh mục thành công.");
                } catch (Exception e) {
                    session.setAttribute("adminError", "Không thể xóa danh mục.");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/categories");
            return;
        }

        List<Category> categories = categoryDao.findAll();
        req.setAttribute("categories", categories);

        req.getRequestDispatcher("/views/admin/categories.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        String name = req.getParameter("name");
        String description = req.getParameter("description");
        String imageUrl = req.getParameter("imageUrl");

        try {
            Category c = new Category();
            if ("update".equals(action)) {
                c.setId(Integer.parseInt(req.getParameter("id")));
            }
            c.setName(name);
            c.setDescription(description);
            c.setImageUrl(imageUrl);

            boolean success;
            if ("update".equals(action)) {
                success = categoryDao.update(c);
                session.setAttribute("adminSuccess", "Cập nhật danh mục thành công.");
            } else {
                success = categoryDao.create(c);
                session.setAttribute("adminSuccess", "Thêm danh mục mới thành công.");
            }

            if (!success) {
                session.setAttribute("adminError", "Thao tác trên danh mục thất bại.");
            }
        } catch (Exception e) {
            session.setAttribute("adminError", "Lỗi dữ liệu danh mục.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/categories");
    }
}

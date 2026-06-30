package com.poly.servlet;

import com.poly.dao.PromotionDao;
import com.poly.entity.Promotion;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/admin/promotions")
public class AdminPromotionServlet extends HttpServlet {
    private final PromotionDao promotionDao = new PromotionDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        if ("edit".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    List<Promotion> list = promotionDao.findAll();
                    for (Promotion p : list) {
                        if (p.getId().equals(Integer.parseInt(idStr))) {
                            req.setAttribute("editingPromotion", p);
                            break;
                        }
                    }
                } catch (NumberFormatException ignored) {}
            }
        } else if ("delete".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    promotionDao.delete(Integer.parseInt(idStr));
                    session.setAttribute("adminSuccess", "Đã xóa mã giảm giá thành công.");
                } catch (Exception e) {
                    session.setAttribute("adminError", "Không thể xóa mã giảm giá.");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/promotions");
            return;
        }

        List<Promotion> promotions = promotionDao.findAll();
        req.setAttribute("promotions", promotions);

        req.getRequestDispatcher("/views/admin/promotions.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        String code = req.getParameter("code");
        String discountType = req.getParameter("discountType");
        String discountValueStr = req.getParameter("discountValue");
        String minOrderValueStr = req.getParameter("minOrderValue");
        String maxDiscountStr = req.getParameter("maxDiscount");
        String activeStr = req.getParameter("active");

        try {
            Promotion p = new Promotion();
            if ("update".equals(action)) {
                p.setId(Integer.parseInt(req.getParameter("id")));
            }
            p.setCode(code.trim().toUpperCase());
            p.setDiscountType(discountType);
            p.setDiscountValue(new BigDecimal(discountValueStr));
            p.setMinOrderValue(minOrderValueStr == null || minOrderValueStr.isEmpty() ? BigDecimal.ZERO : new BigDecimal(minOrderValueStr));
            p.setMaxDiscount(maxDiscountStr == null || maxDiscountStr.isEmpty() ? null : new BigDecimal(maxDiscountStr));
            p.setActive(Boolean.parseBoolean(activeStr));

            boolean success;
            if ("update".equals(action)) {
                success = promotionDao.update(p);
                session.setAttribute("adminSuccess", "Cập nhật mã giảm giá thành công.");
            } else {
                success = promotionDao.create(p);
                session.setAttribute("adminSuccess", "Thêm mã giảm giá mới thành công.");
            }

            if (!success) {
                session.setAttribute("adminError", "Thao tác thất bại. Mã code có thể bị trùng lặp.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("adminError", "Lỗi xử lý dữ liệu khuyến mãi.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/promotions");
    }
}

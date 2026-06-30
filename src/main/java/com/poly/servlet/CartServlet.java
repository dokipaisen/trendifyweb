package com.poly.servlet;

import com.poly.dao.CartDao;
import com.poly.dao.ProductDao;
import com.poly.dao.ProductVariantDao;
import com.poly.dao.PromotionDao;
import com.poly.entity.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private final CartDao cartDao = new CartDao();
    private final ProductDao productDao = new ProductDao();
    private final ProductVariantDao variantDao = new ProductVariantDao();
    private final PromotionDao promotionDao = new PromotionDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        String cleanVoucher = req.getParameter("action");
        if ("clearVoucher".equals(cleanVoucher)) {
            session.removeAttribute("appliedVoucher");
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        List<CartItem> cartItems;
        if (currentUser != null) {
            cartItems = cartDao.findByUserId(currentUser.getId());
        } else {
            List<CartItem> guestCart = (List<CartItem>) session.getAttribute("guestCart");
            if (guestCart == null) {
                guestCart = new ArrayList<>();
                session.setAttribute("guestCart", guestCart);
            }
            cartItems = guestCart;
        }

        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            subtotal = subtotal.add(item.getTotalPrice());
        }

        Promotion voucher = (Promotion) session.getAttribute("appliedVoucher");
        BigDecimal discount = BigDecimal.ZERO;
        if (voucher != null) {
            // Validate minimum order value
            if (subtotal.compareTo(voucher.getMinOrderValue()) < 0) {
                session.removeAttribute("appliedVoucher");
                session.setAttribute("cartError", "Mã giảm giá " + voucher.getCode() + " tự động bị hủy do giá trị đơn chưa đạt tối thiểu " + String.format("%,.0f", voucher.getMinOrderValue()) + "đ.");
                voucher = null;
            } else {
                if ("PERCENTAGE".equals(voucher.getDiscountType())) {
                    BigDecimal calcDiscount = subtotal.multiply(voucher.getDiscountValue().divide(new BigDecimal("100")));
                    if (voucher.getMaxDiscount() != null && calcDiscount.compareTo(voucher.getMaxDiscount()) > 0) {
                        discount = voucher.getMaxDiscount();
                    } else {
                        discount = calcDiscount;
                    }
                } else if ("FIXED_AMOUNT".equals(voucher.getDiscountType())) {
                    discount = voucher.getDiscountValue();
                }
            }
        }

        BigDecimal total = subtotal.subtract(discount);
        if (total.compareTo(BigDecimal.ZERO) < 0) {
            total = BigDecimal.ZERO;
        }

        // Store counts in session
        session.setAttribute("cartSize", cartItems.size());
        req.setAttribute("cartItems", cartItems);
        req.setAttribute("cartSubtotal", subtotal);
        req.setAttribute("discountAmount", discount);
        req.setAttribute("cartTotal", total);

        req.getRequestDispatcher("/views/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        String action = req.getParameter("action");

        if ("add".equals(action)) {
            String productIdStr = req.getParameter("productId");
            String variantIdStr = req.getParameter("variantId");
            String quantityStr = req.getParameter("quantity");

            try {
                int productId = Integer.parseInt(productIdStr);
                int variantId = Integer.parseInt(variantIdStr);
                int quantity = Integer.parseInt(quantityStr);

                Product product = productDao.findById(productId);
                ProductVariant variant = variantDao.findById(variantId);

                if (product != null && variant != null) {
                    if (currentUser != null) {
                        // DB Save
                        CartItem item = new CartItem();
                        item.setUserId(currentUser.getId());
                        item.setProductId(productId);
                        item.setVariantId(variantId);
                        item.setQuantity(quantity);
                        cartDao.addToCart(item);
                        
                        // Recalculate cart count
                        session.setAttribute("cartSize", cartDao.findByUserId(currentUser.getId()).size());
                    } else {
                        // Session Save
                        List<CartItem> guestCart = (List<CartItem>) session.getAttribute("guestCart");
                        if (guestCart == null) {
                            guestCart = new ArrayList<>();
                        }

                        boolean found = false;
                        for (CartItem ci : guestCart) {
                            if (ci.getVariantId().equals(variantId)) {
                                ci.setQuantity(ci.getQuantity() + quantity);
                                found = true;
                                break;
                            }
                        }

                        if (!found) {
                            CartItem item = new CartItem();
                            item.setUserId(null);
                            item.setProductId(productId);
                            item.setVariantId(variantId);
                            item.setQuantity(quantity);
                            item.setProductName(product.getName());
                            item.setProductBrand(product.getBrand());
                            item.setProductImageUrl(product.getImageUrl());
                            item.setPrice(product.getPrice());
                            item.setSize(variant.getSize());
                            item.setColor(variant.getColor());
                            guestCart.add(item);
                        }

                        session.setAttribute("guestCart", guestCart);
                        session.setAttribute("cartSize", guestCart.size());
                    }
                    session.setAttribute("cartSuccess", "Đã thêm sản phẩm vào giỏ hàng.");
                } else {
                    session.setAttribute("cartError", "Sản phẩm hoặc phân loại không tồn tại.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("cartError", "Có lỗi xảy ra khi thêm vào giỏ hàng.");
            }
            resp.sendRedirect(req.getContextPath() + "/product/detail?id=" + productIdStr);

        } else if ("update".equals(action)) {
            String variantIdStr = req.getParameter("variantId");
            String quantityStr = req.getParameter("quantity");

            try {
                int variantId = Integer.parseInt(variantIdStr);
                int quantity = Integer.parseInt(quantityStr);

                if (currentUser != null) {
                    cartDao.updateQuantity(currentUser.getId(), variantId, quantity);
                } else {
                    List<CartItem> guestCart = (List<CartItem>) session.getAttribute("guestCart");
                    if (guestCart != null) {
                        for (CartItem ci : guestCart) {
                            if (ci.getVariantId().equals(variantId)) {
                                ci.setQuantity(quantity);
                                break;
                            }
                        }
                    }
                }
                session.setAttribute("cartSuccess", "Cập nhật giỏ hàng thành công.");
            } catch (Exception e) {
                session.setAttribute("cartError", "Cập nhật giỏ hàng thất bại.");
            }
            resp.sendRedirect(req.getContextPath() + "/cart");

        } else if ("delete".equals(action)) {
            String variantIdStr = req.getParameter("variantId");

            try {
                int variantId = Integer.parseInt(variantIdStr);

                if (currentUser != null) {
                    cartDao.deleteItem(currentUser.getId(), variantId);
                    session.setAttribute("cartSize", cartDao.findByUserId(currentUser.getId()).size());
                } else {
                    List<CartItem> guestCart = (List<CartItem>) session.getAttribute("guestCart");
                    if (guestCart != null) {
                        guestCart.removeIf(ci -> ci.getVariantId().equals(variantId));
                        session.setAttribute("cartSize", guestCart.size());
                    }
                }
                session.setAttribute("cartSuccess", "Đã xóa sản phẩm khỏi giỏ hàng.");
            } catch (Exception e) {
                session.setAttribute("cartError", "Xóa sản phẩm thất bại.");
            }
            resp.sendRedirect(req.getContextPath() + "/cart");

        } else if ("voucher".equals(action)) {
            String code = req.getParameter("voucherCode");
            if (code != null && !code.trim().isEmpty()) {
                Promotion voucher = promotionDao.findByCode(code.trim().toUpperCase());
                if (voucher != null) {
                    session.setAttribute("appliedVoucher", voucher);
                    session.setAttribute("cartSuccess", "Đã áp dụng mã giảm giá " + voucher.getCode() + " thành công!");
                } else {
                    session.removeAttribute("appliedVoucher");
                    session.setAttribute("cartError", "Mã giảm giá không hợp lệ hoặc đã hết hạn.");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/cart");
        }
    }
}

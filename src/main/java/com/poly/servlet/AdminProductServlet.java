package com.poly.servlet;

import com.poly.dao.CategoryDao;
import com.poly.dao.ProductDao;
import com.poly.dao.ProductVariantDao;
import com.poly.entity.Category;
import com.poly.entity.Product;
import com.poly.entity.ProductVariant;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.List;

@WebServlet("/admin/products")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AdminProductServlet extends HttpServlet {
    private final ProductDao productDao = new ProductDao();
    private final CategoryDao categoryDao = new CategoryDao();
    private final ProductVariantDao variantDao = new ProductVariantDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        if ("edit".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    Product p = productDao.findById(Integer.parseInt(idStr));
                    req.setAttribute("editingProduct", p);
                } catch (NumberFormatException ignored) {}
            }
        } else if ("variant".equals(action)) {
            String idStr = req.getParameter("id");
            String editVariantIdStr = req.getParameter("editVariantId");
            if (idStr != null) {
                try {
                    int productId = Integer.parseInt(idStr);
                    Product p = productDao.findById(productId);
                    List<ProductVariant> variants = variantDao.findByProductId(productId);
                    req.setAttribute("selectedProductForVariants", p);
                    req.setAttribute("variantsList", variants);

                    if (editVariantIdStr != null) {
                        int editVariantId = Integer.parseInt(editVariantIdStr);
                        for (ProductVariant v : variants) {
                            if (v.getId() == editVariantId) {
                                req.setAttribute("editingVariant", v);
                                break;
                            }
                        }
                    }
                } catch (NumberFormatException ignored) {}
            }
        } else if ("delete".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    productDao.delete(Integer.parseInt(idStr));
                    session.setAttribute("adminSuccess", "Đã xóa sản phẩm thành công.");
                } catch (Exception e) {
                    session.setAttribute("adminError", "Không thể xóa sản phẩm do tồn tại đơn hàng liên kết.");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        } else if ("deleteVariant".equals(action)) {
            String variantIdStr = req.getParameter("variantId");
            String productIdStr = req.getParameter("productId");
            if (variantIdStr != null) {
                try {
                    variantDao.delete(Integer.parseInt(variantIdStr));
                    session.setAttribute("adminSuccess", "Đã xóa biến thể thành công.");
                } catch (Exception e) {
                    session.setAttribute("adminError", "Không thể xóa biến thể.");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/products?action=variant&id=" + productIdStr);
            return;
        }

        List<Product> products = productDao.findAll(null, null, null, null, null, "ALL");
        List<Category> categories = categoryDao.findAll();

        req.setAttribute("products", products);
        req.setAttribute("categories", categories);

        req.getRequestDispatcher("/views/admin/products.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        if ("create".equals(action) || "update".equals(action)) {
            String name = req.getParameter("name");
            String brand = req.getParameter("brand");
            String categoryIdStr = req.getParameter("categoryId");
            String priceStr = req.getParameter("price");
            String originalPriceStr = req.getParameter("originalPrice");
            String status = req.getParameter("status");
            String description = req.getParameter("description");

            try {
                String imageUrl = req.getParameter("imageUrl");
                Part part = req.getPart("imageFile");
                if (part != null && part.getSize() > 0) {
                    String submittedFileName = part.getSubmittedFileName();
                    if (submittedFileName != null && !submittedFileName.isEmpty()) {
                        String fileName = Paths.get(submittedFileName).getFileName().toString();
                        String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                        String uploadPath = req.getServletContext().getRealPath("/uploads");
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }
                        part.write(uploadPath + File.separator + uniqueFileName);
                        imageUrl = req.getContextPath() + "/uploads/" + uniqueFileName;
                    }
                }

                Product p = new Product();
                if ("update".equals(action)) {
                    p.setId(Integer.parseInt(req.getParameter("id")));
                }
                p.setName(name);
                p.setBrand(brand);
                p.setCategoryId(categoryIdStr == null || categoryIdStr.isEmpty() ? null : Integer.parseInt(categoryIdStr));
                p.setPrice(new BigDecimal(priceStr));
                p.setOriginalPrice(originalPriceStr == null || originalPriceStr.isEmpty() ? null : new BigDecimal(originalPriceStr));
                p.setImageUrl(imageUrl);
                p.setStatus(status);
                p.setDescription(description);

                boolean success;
                if ("update".equals(action)) {
                    success = productDao.update(p);
                    session.setAttribute("adminSuccess", "Cập nhật sản phẩm thành công.");
                } else {
                    success = productDao.create(p);
                    session.setAttribute("adminSuccess", "Thêm sản phẩm mới thành công.");
                }

                if (!success) {
                    session.setAttribute("adminError", "Thao tác trên sản phẩm thất bại.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("adminError", "Lỗi xử lý dữ liệu sản phẩm.");
            }
            resp.sendRedirect(req.getContextPath() + "/admin/products");

        } else if ("createVariant".equals(action)) {
            String productIdStr = req.getParameter("productId");
            String size = req.getParameter("size");
            String color = req.getParameter("color");
            String stockStr = req.getParameter("stock");
            String sku = req.getParameter("sku");

            try {
                int productId = Integer.parseInt(productIdStr);
                int stock = Integer.parseInt(stockStr);

                if (sku == null || sku.trim().isEmpty()) {
                    sku = "TDF-SP" + productId + "-" + size.toUpperCase() + "-" + color.toUpperCase();
                }

                ProductVariant pv = new ProductVariant();
                pv.setProductId(productId);
                pv.setSize(size.toUpperCase());
                pv.setColor(color);
                pv.setStock(stock);
                pv.setSku(sku.trim().toUpperCase());

                boolean success = variantDao.create(pv);
                if (success) {
                    session.setAttribute("adminSuccess", "Thêm biến thể mới thành công.");
                } else {
                    session.setAttribute("adminError", "Thêm biến thể thất bại. SKU có thể đã bị trùng lặp.");
                }
            } catch (Exception e) {
                session.setAttribute("adminError", "Lỗi xử lý dữ liệu biến thể.");
            }
            resp.sendRedirect(req.getContextPath() + "/admin/products?action=variant&id=" + productIdStr);

        } else if ("updateVariantStock".equals(action)) {
            String productIdStr = req.getParameter("productId");
            String variantIdStr = req.getParameter("variantId");
            String stockStr = req.getParameter("stock");

            try {
                int variantId = Integer.parseInt(variantIdStr);
                int stock = Integer.parseInt(stockStr);

                variantDao.updateStock(variantId, stock);
                session.setAttribute("adminSuccess", "Cập nhật số lượng tồn kho thành công.");
            } catch (Exception e) {
                session.setAttribute("adminError", "Cập nhật tồn kho thất bại.");
            }
            resp.sendRedirect(req.getContextPath() + "/admin/products?action=variant&id=" + productIdStr);

        } else if ("updateVariant".equals(action)) {
            String productIdStr = req.getParameter("productId");
            String variantIdStr = req.getParameter("variantId");
            String size = req.getParameter("size");
            String color = req.getParameter("color");
            String stockStr = req.getParameter("stock");
            String sku = req.getParameter("sku");

            try {
                int productId = Integer.parseInt(productIdStr);
                int variantId = Integer.parseInt(variantIdStr);
                int stock = Integer.parseInt(stockStr);

                if (sku == null || sku.trim().isEmpty()) {
                    sku = "TDF-SP" + productId + "-" + size.toUpperCase() + "-" + color.toUpperCase();
                }

                ProductVariant pv = new ProductVariant();
                pv.setId(variantId);
                pv.setProductId(productId);
                pv.setSize(size.toUpperCase());
                pv.setColor(color);
                pv.setStock(stock);
                pv.setSku(sku.trim().toUpperCase());

                boolean success = variantDao.update(pv);
                if (success) {
                    session.setAttribute("adminSuccess", "Cập nhật biến thể thành công.");
                } else {
                    session.setAttribute("adminError", "Cập nhật biến thể thất bại. SKU có thể đã bị trùng lặp.");
                }
            } catch (Exception e) {
                session.setAttribute("adminError", "Lỗi xử lý dữ liệu cập nhật biến thể.");
            }
            resp.sendRedirect(req.getContextPath() + "/admin/products?action=variant&id=" + productIdStr);
        }
    }
}

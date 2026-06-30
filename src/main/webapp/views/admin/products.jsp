<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout.jsp">
    <jsp:param name="pageTitle" value="Trendify Admin - Sản Phẩm" />
    <jsp:param name="pageHeader" value="Quản Lý Sản Phẩm & Biến Thể" />
    <jsp:param name="activeNav" value="products" />
</jsp:include>

    <c:if test="${not empty sessionScope.adminSuccess}">
        <div class="alert alert-success">
            <span><c:out value="${sessionScope.adminSuccess}"/></span>
            <button onclick="this.parentElement.style.display='none'" style="background:none; border:none; cursor:pointer; font-weight:bold;">[Đóng]</button>
        </div>
        <% session.removeAttribute("adminSuccess"); %>
    </c:if>
    <c:if test="${not empty sessionScope.adminError}">
        <div class="alert alert-danger" style="border-color: #999;">
            <span style="color: #666;"><c:out value="${sessionScope.adminError}"/></span>
            <button onclick="this.parentElement.style.display='none'" style="background:none; border:none; cursor:pointer; font-weight:bold;">[Đóng]</button>
        </div>
        <% session.removeAttribute("adminError"); %>
    </c:if>

    <div style="display: flex; gap: 40px; flex-wrap: wrap; margin-bottom: 40px;">
        <!-- Left: Form to Add/Edit Product -->
        <div style="flex: 1; min-width: 320px; background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px; align-self: flex-start;">
            <h3 style="font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                ${editingProduct != null ? 'Cập Nhật Sản Phẩm' : 'Thêm Sản Phẩm Mới'}
            </h3>

            <form action="${pageContext.request.contextPath}/admin/products" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" value="${editingProduct != null ? 'update' : 'create'}">
                <c:if test="${editingProduct != null}">
                    <input type="hidden" name="id" value="${editingProduct.id}">
                </c:if>

                <div class="form-group">
                    <label for="name">Tên Sản Phẩm *</label>
                    <input type="text" id="name" name="name" value="<c:out value="${editingProduct != null ? editingProduct.name : ''}"/>" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="brand">Thương Hiệu *</label>
                    <input type="text" id="brand" name="brand" value="<c:out value="${editingProduct != null ? editingProduct.brand : ''}"/>" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="categoryId">Danh Mục *</label>
                    <select id="categoryId" name="categoryId" required style="width: 100%;">
                        <option value="">-- Chọn danh mục --</option>
                        <c:forEach var="c" items="${categories}">
                            <option value="${c.id}" ${editingProduct != null and editingProduct.categoryId == c.id ? 'selected' : ''}>
                                <c:out value="${c.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="price">Giá Bán * (đ)</label>
                    <input type="number" id="price" name="price" value="${editingProduct != null ? editingProduct.price : ''}" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="originalPrice">Giá Gốc (đ)</label>
                    <input type="number" id="originalPrice" name="originalPrice" value="${editingProduct != null ? editingProduct.originalPrice : ''}" style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="imageFile">Ảnh Sản Phẩm * ${editingProduct != null ? '(Tải ảnh mới nếu muốn thay đổi)' : ''}</label>
                    <input type="file" id="imageFile" name="imageFile" accept="image/*" ${editingProduct != null ? '' : 'required'} style="width: 100%;">
                    <c:if test="${editingProduct != null}">
                        <div style="margin-top: 10px;">
                            <span style="font-size: 11px; color: var(--text-secondary);">Ảnh hiện tại:</span><br>
                            <img src="${editingProduct.imageUrl}" style="width: 60px; height: 80px; object-fit: cover; margin-top: 5px; border: 1px solid var(--border-color);">
                            <input type="hidden" name="imageUrl" value="<c:out value="${editingProduct.imageUrl}"/>">
                        </div>
                    </c:if>
                </div>

                <div class="form-group">
                    <label for="status">Trạng Thái</label>
                    <select id="status" name="status" style="width: 100%;">
                        <option value="ACTIVE" ${editingProduct != null and editingProduct.status == 'ACTIVE' ? 'selected' : ''}>Hoạt động (ACTIVE)</option>
                        <option value="INACTIVE" ${editingProduct != null and editingProduct.status == 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động (INACTIVE)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="description">Mô Tả Sản Phẩm</label>
                    <textarea id="description" name="description" rows="4" style="width: 100%; resize: vertical;"><c:out value="${editingProduct != null ? editingProduct.description : ''}"/></textarea>
                </div>

                <div style="display: flex; gap: 10px; margin-top: 25px;">
                    <button type="submit" class="btn btn-dark" style="flex-grow: 1;">
                        ${editingProduct != null ? 'Cập Nhật' : 'Thêm Sản Phẩm'}
                    </button>
                    <c:if test="${editingProduct != null}">
                        <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-light">Hủy</a>
                    </c:if>
                </div>
            </form>
        </div>

        <!-- Right: Products Listing Table -->
        <div style="flex: 2; min-width: 450px; background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px;">
            <h3 style="font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                Danh Sách Sản Phẩm (${products.size()})
            </h3>

            <table class="admin-table" style="width: 100%;">
                <thead>
                    <tr>
                        <th style="width: 60px;">Ảnh</th>
                        <th>Sản Phẩm</th>
                        <th>Danh Mục</th>
                        <th>Giá Bán</th>
                        <th>Trạng Thái</th>
                        <th style="width: 180px; text-align: right;">Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${products}">
                        <tr>
                            <td>
                                <img src="${p.imageUrl}" alt="${p.name}" style="width: 40px; height: 50px; object-fit: cover; border: 1px solid var(--border-color);">
                            </td>
                            <td>
                                <div style="font-weight: 600;"><c:out value="${p.name}"/></div>
                                <div style="font-size: 11px; color: var(--text-secondary); text-transform: uppercase;"><c:out value="${p.brand}"/></div>
                            </td>
                            <td><c:out value="${p.categoryName}"/></td>
                            <td style="font-weight: 600;">
                                <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </td>
                            <td>
                                <span class="status-badge ${p.status == 'ACTIVE' ? 'status-success' : 'status-pending'}">
                                    ${p.status == 'ACTIVE' ? 'Hoạt động' : 'Khóa'}
                                </span>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: flex; gap: 8px; justify-content: flex-end;">
                                    <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${p.id}" class="btn btn-light" style="font-size: 11px; padding: 4px 8px;">Sửa</a>
                                    <a href="${pageContext.request.contextPath}/admin/products?action=variant&id=${p.id}" class="btn btn-dark" style="font-size: 11px; padding: 4px 8px;">Biến Thể</a>
                                    <a href="${pageContext.request.contextPath}/admin/products?action=delete&id=${p.id}" class="btn btn-light" style="font-size: 11px; padding: 4px 8px; border-color: #ccc; color: #999;" onclick="return confirm('Bạn chắc chắn muốn xóa sản phẩm này?')">Xóa</a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Variant Details Section (If product variant view requested) -->
    <c:if test="${not empty selectedProductForVariants}">
        <div style="background-color: var(--bg-primary); border: 1px solid var(--border-color-dark); padding: 30px; margin-top: 30px;">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); padding-bottom: 15px; margin-bottom: 20px;">
                <h3 style="font-size: 15px; font-weight: 700; text-transform: uppercase;">
                    Quản lý biến thể cho: <c:out value="${selectedProductForVariants.name}"/>
                </h3>
                <a href="${pageContext.request.contextPath}/admin/products" style="font-size: 12px; text-decoration: underline; color: #000; font-weight: 600;">Đóng quản lý biến thể</a>
            </div>

            <div style="display: flex; gap: 40px; flex-wrap: wrap;">
                <!-- Add/Edit Variant Form -->
                <div style="flex: 1; min-width: 280px; border-right: 1px solid var(--border-color); padding-right: 30px;">
                    <h4 style="font-size: 13px; font-weight: 700; text-transform: uppercase; margin-bottom: 15px;">
                        ${editingVariant != null ? 'Cập Nhật Biến Thể' : 'Thêm Biến Thể Mới'}
                    </h4>
                    <form action="${pageContext.request.contextPath}/admin/products" method="POST">
                        <input type="hidden" name="action" value="${editingVariant != null ? 'updateVariant' : 'createVariant'}">
                        <input type="hidden" name="productId" value="${selectedProductForVariants.id}">
                        <c:if test="${editingVariant != null}">
                            <input type="hidden" name="variantId" value="${editingVariant.id}">
                        </c:if>

                        <div class="form-group">
                            <label for="size">Kích Cỡ * (VD: S, M, L, XL, 38, 39)</label>
                            <input type="text" id="size" name="size" value="<c:out value="${editingVariant != null ? editingVariant.size : ''}"/>" required style="width: 100%;">
                        </div>

                        <div class="form-group">
                            <label for="color">Màu Sắc * (VD: Đen, Trắng, Xám, Be)</label>
                            <input type="text" id="color" name="color" value="<c:out value="${editingVariant != null ? editingVariant.color : ''}"/>" required style="width: 100%;">
                        </div>

                        <div class="form-group">
                            <label for="stock">Số Lượng Tồn Kho *</label>
                            <input type="number" id="stock" name="stock" value="${editingVariant != null ? editingVariant.stock : '10'}" min="0" required style="width: 100%;">
                        </div>

                        <div class="form-group">
                            <label for="sku">Mã SKU (Tự động hoặc nhập riêng)</label>
                            <input type="text" id="sku" name="sku" value="<c:out value="${editingVariant != null ? editingVariant.sku : ''}"/>" placeholder="VD: SP-${selectedProductForVariants.id}-M-DEN" style="width: 100%;">
                        </div>

                        <div style="display: flex; gap: 10px; margin-top: 20px;">
                            <button type="submit" class="btn btn-dark" style="flex-grow: 1;">
                                ${editingVariant != null ? 'Cập Nhật' : 'Thêm Biến Thể'}
                            </button>
                            <c:if test="${editingVariant != null}">
                                <a href="${pageContext.request.contextPath}/admin/products?action=variant&id=${selectedProductForVariants.id}" class="btn btn-light">Hủy</a>
                            </c:if>
                        </div>
                    </form>
                </div>

                <!-- Existing Variants Table -->
                <div style="flex: 2; min-width: 400px;">
                    <h4 style="font-size: 13px; font-weight: 700; text-transform: uppercase; margin-bottom: 15px;">Danh Sách Biến Thể Hiện Có</h4>
                    <c:choose>
                        <c:when test="${not empty variantsList}">
                            <table class="admin-table">
                                <thead>
                                    <tr>
                                        <th>Mã SKU</th>
                                        <th>Kích Cỡ</th>
                                        <th>Màu Sắc</th>
                                        <th>Tồn Kho</th>
                                        <th style="text-align: right;">Hành Động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="v" items="${variantsList}">
                                        <tr>
                                            <td style="font-family: monospace; font-weight: 600;"><c:out value="${v.sku}"/></td>
                                            <td><c:out value="${v.size}"/></td>
                                            <td><c:out value="${v.color}"/></td>
                                            <td>
                                                <form action="${pageContext.request.contextPath}/admin/products" method="POST" style="display: flex; gap: 5px; align-items: center;">
                                                    <input type="hidden" name="action" value="updateVariantStock">
                                                    <input type="hidden" name="productId" value="${selectedProductForVariants.id}">
                                                    <input type="hidden" name="variantId" value="${v.id}">
                                                    <input type="number" name="stock" value="${v.stock}" min="0" style="width: 60px; padding: 4px;">
                                                    <button type="submit" class="btn btn-light" style="padding: 4px 8px; font-size: 10px;">Lưu</button>
                                                </form>
                                            </td>
                                            <td style="text-align: right;">
                                                <div style="display: flex; gap: 6px; justify-content: flex-end;">
                                                    <a href="${pageContext.request.contextPath}/admin/products?action=variant&id=${selectedProductForVariants.id}&editVariantId=${v.id}" 
                                                       class="btn btn-light" style="font-size: 10px; padding: 4px 8px;">Sửa</a>
                                                    <a href="${pageContext.request.contextPath}/admin/products?action=deleteVariant&variantId=${v.id}&productId=${selectedProductForVariants.id}" 
                                                       class="btn btn-light" style="font-size: 10px; padding: 4px 8px; color: #999; border-color: #ccc;"
                                                       onclick="return confirm('Bạn chắc chắn muốn xóa biến thể này?')">Xóa</a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
                            <div style="padding: 30px; text-align: center; border: 1px dashed var(--border-color); color: var(--text-secondary);">
                                Chưa có biến thể nào cho sản phẩm này.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </c:if>

<jsp:include page="layout_footer.jsp" />

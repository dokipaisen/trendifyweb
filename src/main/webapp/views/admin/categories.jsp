<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="layout.jsp">
    <jsp:param name="pageTitle" value="Trendify Admin - Danh Mục" />
    <jsp:param name="pageHeader" value="Quản Lý Danh Mục Sản Phẩm" />
    <jsp:param name="activeNav" value="categories" />
</jsp:include>

    <c:if test="${not empty sessionScope.adminSuccess}">
        <div class="alert alert-success">
            <span><c:out value="${sessionScope.adminSuccess}"/></span>
            <button onclick="this.parentElement.style.display='none'" style="background:none; border:none; cursor:pointer; font-weight:bold;">[Đóng]</button>
        </div>
        <% session.removeAttribute("adminSuccess"); %>
    </c:if>

    <div style="display: flex; gap: 40px; flex-wrap: wrap;">
        <!-- Left: Form to Add/Edit Category -->
        <div style="flex: 1; min-width: 300px; background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px; align-self: flex-start;">
            <h3 style="font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                ${editingCategory != null ? 'Cập Nhật Danh Mục' : 'Thêm Danh Mục Mới'}
            </h3>

            <form action="${pageContext.request.contextPath}/admin/categories" method="POST">
                <input type="hidden" name="action" value="${editingCategory != null ? 'update' : 'create'}">
                <c:if test="${editingCategory != null}">
                    <input type="hidden" name="id" value="${editingCategory.id}">
                </c:if>

                <div class="form-group">
                    <label for="name">Tên Danh Mục *</label>
                    <input type="text" id="name" name="name" value="<c:out value="${editingCategory != null ? editingCategory.name : ''}"/>" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="imageUrl">Link Ảnh Minh Họa (URL)</label>
                    <input type="text" id="imageUrl" name="imageUrl" value="<c:out value="${editingCategory != null ? editingCategory.imageUrl : ''}"/>" style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="description">Mô Tả Chi Tiết</label>
                    <textarea id="description" name="description" rows="3" style="width: 100%; resize: vertical;"><c:out value="${editingCategory != null ? editingCategory.description : ''}"/></textarea>
                </div>

                <div style="display: flex; gap: 10px; margin-top: 25px;">
                    <button type="submit" class="btn btn-dark" style="flex-grow: 1;">
                        ${editingCategory != null ? 'Cập Nhật' : 'Thêm Danh Mục'}
                    </button>
                    <c:if test="${editingCategory != null}">
                        <a href="${pageContext.request.contextPath}/admin/categories" class="btn btn-light">Hủy</a>
                    </c:if>
                </div>
            </form>
        </div>

        <!-- Right: Categories List Table -->
        <div style="flex: 2; min-width: 400px; background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px;">
            <h3 style="font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                Danh Sách Danh Mục Hiện Có
            </h3>

            <table class="admin-table">
                <thead>
                    <tr>
                        <th style="width: 60px;">Ảnh</th>
                        <th>Tên Danh Mục</th>
                        <th>Mô Tả</th>
                        <th style="text-align: right; width: 120px;">Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${categories}">
                        <tr>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty c.imageUrl}">
                                        <img src="${c.imageUrl}" alt="${c.name}" style="width: 40px; height: 40px; object-fit: cover; border: 1px solid var(--border-color);">
                                    </c:when>
                                    <c:otherwise>
                                        <div style="width: 40px; height: 40px; background-color: var(--bg-secondary); border: 1px solid var(--border-color); display: flex; align-items: center; justify-content: center; font-size: 10px; color: var(--text-muted);">None</div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="font-weight: 600;"><c:out value="${c.name}"/></td>
                            <td><c:out value="${c.description}"/></td>
                            <td style="text-align: right;">
                                <div style="display: flex; gap: 8px; justify-content: flex-end;">
                                    <a href="${pageContext.request.contextPath}/admin/categories?action=edit&id=${c.id}" class="btn btn-light" style="font-size: 11px; padding: 4px 8px;">Sửa</a>
                                    <a href="${pageContext.request.contextPath}/admin/categories?action=delete&id=${c.id}" class="btn btn-light" style="font-size: 11px; padding: 4px 8px; border-color: #ccc; color: #999;" onclick="return confirm('Bạn chắc chắn muốn xóa danh mục này? Tất cả sản phẩm thuộc danh mục sẽ được giữ lại và set danh mục về NULL.')">Xóa</a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

<jsp:include page="layout_footer.jsp" />

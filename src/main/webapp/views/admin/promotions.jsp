<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout.jsp">
    <jsp:param name="pageTitle" value="Trendify Admin - Mã giảm giá" />
    <jsp:param name="pageHeader" value="Quản Lý Mã Giảm Giá & Voucher" />
    <jsp:param name="activeNav" value="promotions" />
</jsp:include>

    <c:if test="${not empty sessionScope.adminSuccess}">
        <div class="alert alert-success">
            <span><c:out value="${sessionScope.adminSuccess}"/></span>
            <button onclick="this.parentElement.style.display='none'" style="background:none; border:none; cursor:pointer; font-weight:bold;">[Đóng]</button>
        </div>
        <% session.removeAttribute("adminSuccess"); %>
    </c:if>

    <div style="display: flex; gap: 40px; flex-wrap: wrap;">
        <!-- Left: Form to Add/Edit Promotion -->
        <div style="flex: 1; min-width: 300px; background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px; align-self: flex-start;">
            <h3 style="font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                ${editingPromotion != null ? 'Cập Nhật Voucher' : 'Thêm Voucher Mới'}
            </h3>

            <form action="${pageContext.request.contextPath}/admin/promotions" method="POST">
                <input type="hidden" name="action" value="${editingPromotion != null ? 'update' : 'create'}">
                <c:if test="${editingPromotion != null}">
                    <input type="hidden" name="id" value="${editingPromotion.id}">
                </c:if>

                <div class="form-group">
                    <label for="code">Mã Giảm Giá * (Viết hoa không cách)</label>
                    <input type="text" id="code" name="code" value="<c:out value="${editingPromotion != null ? editingPromotion.code : ''}"/>" required style="width: 100%; text-transform: uppercase;">
                </div>

                <div class="form-group">
                    <label for="discountType">Loại Giảm Giá *</label>
                    <select id="discountType" name="discountType" required style="width: 100%;">
                        <option value="PERCENTAGE" ${editingPromotion != null and editingPromotion.discountType == 'PERCENTAGE' ? 'selected' : ''}>Phần trăm (PERCENTAGE)</option>
                        <option value="FIXED_AMOUNT" ${editingPromotion != null and editingPromotion.discountType == 'FIXED_AMOUNT' ? 'selected' : ''}>Số tiền cố định (FIXED_AMOUNT)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="discountValue">Giá Trị Giảm * (VD: 10 cho %, hoặc 50000 cho VND)</label>
                    <input type="number" id="discountValue" name="discountValue" value="${editingPromotion != null ? editingPromotion.discountValue : ''}" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="minOrderValue">Đơn Hàng Tối Thiểu (đ)</label>
                    <input type="number" id="minOrderValue" name="minOrderValue" value="${editingPromotion != null ? editingPromotion.minOrderValue : '0'}" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="maxDiscount">Mức Giảm Tối Đa (đ - cho loại phần trăm)</label>
                    <input type="number" id="maxDiscount" name="maxDiscount" value="${editingPromotion != null ? editingPromotion.maxDiscount : ''}" style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="active">Trạng Thái</label>
                    <select id="active" name="active" style="width: 100%;">
                        <option value="true" ${editingPromotion != null and editingPromotion.active ? 'selected' : ''}>Kích hoạt (ACTIVE)</option>
                        <option value="false" ${editingPromotion != null and not editingPromotion.active ? 'selected' : ''}>Tạm khóa (DISABLED)</option>
                    </select>
                </div>

                <div style="display: flex; gap: 10px; margin-top: 25px;">
                    <button type="submit" class="btn btn-dark" style="flex-grow: 1;">
                        ${editingPromotion != null ? 'Cập Nhật' : 'Thêm Voucher'}
                    </button>
                    <c:if test="${editingPromotion != null}">
                        <a href="${pageContext.request.contextPath}/admin/promotions" class="btn btn-light">Hủy</a>
                    </c:if>
                </div>
            </form>
        </div>

        <!-- Right: Promotions List Table -->
        <div style="flex: 2; min-width: 400px; background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px;">
            <h3 style="font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                Danh Sách Voucher
            </h3>

            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Mã Code</th>
                        <th>Loại Giảm</th>
                        <th>Giá Trị</th>
                        <th>Đơn Tối Thiểu</th>
                        <th>Trạng Thái</th>
                        <th style="text-align: right; width: 120px;">Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${promotions}">
                        <tr>
                            <td style="font-family: monospace; font-weight: 600; text-transform: uppercase;"><c:out value="${p.code}"/></td>
                            <td>${p.discountType == 'PERCENTAGE' ? 'Phần Trăm (%)' : 'Tiền Mặt'}</td>
                            <td style="font-weight: 600;">
                                <c:choose>
                                    <c:when test="${p.discountType == 'PERCENTAGE'}">
                                        ${p.discountValue}%
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${p.discountValue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <fmt:formatNumber value="${p.minOrderValue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </td>
                            <td>
                                <span class="status-badge ${p.active ? 'status-success' : 'status-pending'}">
                                    ${p.active ? 'Kích hoạt' : 'Khóa'}
                                </span>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: flex; gap: 8px; justify-content: flex-end;">
                                    <a href="${pageContext.request.contextPath}/admin/promotions?action=edit&id=${p.id}" class="btn btn-light" style="font-size: 11px; padding: 4px 8px;">Sửa</a>
                                    <a href="${pageContext.request.contextPath}/admin/promotions?action=delete&id=${p.id}" class="btn btn-light" style="font-size: 11px; padding: 4px 8px; border-color: #ccc; color: #999;" onclick="return confirm('Bạn chắc chắn muốn xóa voucher này?')">Xóa</a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

<jsp:include page="layout_footer.jsp" />

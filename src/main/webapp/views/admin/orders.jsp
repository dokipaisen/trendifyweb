<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout.jsp">
    <jsp:param name="pageTitle" value="Trendify Admin - Đơn Hàng" />
    <jsp:param name="pageHeader" value="Quản Lý Đơn Hàng" />
    <jsp:param name="activeNav" value="orders" />
</jsp:include>

    <c:if test="${not empty sessionScope.adminSuccess}">
        <div class="alert alert-success">
            <span><c:out value="${sessionScope.adminSuccess}"/></span>
            <button onclick="this.parentElement.style.display='none'" style="background:none; border:none; cursor:pointer; font-weight:bold;">[Đóng]</button>
        </div>
        <% session.removeAttribute("adminSuccess"); %>
    </c:if>

    <!-- Orders List Table -->
    <div style="background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px; margin-bottom: 40px;">
        <h3 style="font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
            Danh Sách Đơn Hàng (${orders.size()})
        </h3>

        <table class="admin-table">
            <thead>
                <tr>
                    <th>Mã Đơn Hàng</th>
                    <th>Khách Hàng</th>
                    <th>Điện Thoại</th>
                    <th>Ngày Đặt</th>
                    <th>Tổng Tiền</th>
                    <th>Thanh Toán</th>
                    <th>Giao Hàng</th>
                    <th style="text-align: right;">Hành Động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="o" items="${orders}">
                    <tr>
                        <td style="font-weight: 600;"><c:out value="${o.orderCode}"/></td>
                        <td><c:out value="${o.fullName}"/></td>
                        <td><c:out value="${o.phone}"/></td>
                        <td><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                        <td style="font-weight: 600;">
                            <fmt:formatNumber value="${o.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </td>
                        <td>
                            <span class="status-badge ${o.paymentStatus == 'PAID' ? 'status-success' : 'status-pending'}">
                                ${o.paymentStatus == 'PAID' ? 'Đã thanh toán' : 'Chưa thanh toán'}
                            </span>
                        </td>
                        <td>
                            <span class="status-badge <c:choose>
                                <c:when test="${o.status == 'DELIVERED'}">status-success</c:when>
                                <c:when test="${o.status == 'CANCELLED'}">status-danger</c:when>
                                <c:otherwise>status-pending</c:otherwise>
                            </c:choose>">
                                <c:choose>
                                    <c:when test="${o.status == 'PENDING'}">Chờ xác nhận</c:when>
                                    <c:when test="${o.status == 'CONFIRMED'}">Đã xác nhận</c:when>
                                    <c:when test="${o.status == 'PROCESSING'}">Đang xử lý</c:when>
                                    <c:when test="${o.status == 'SHIPPING'}">Đang giao</c:when>
                                    <c:when test="${o.status == 'DELIVERED'}">Đã giao</c:when>
                                    <c:when test="${o.status == 'CANCELLED'}">Đã hủy</c:when>
                                </c:choose>
                            </span>
                        </td>
                        <td style="text-align: right;">
                            <a href="${pageContext.request.contextPath}/admin/orders?action=detail&id=${o.id}" class="btn btn-dark" style="font-size: 11px; padding: 4px 10px;">Chi Tiết</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Order Detail & Status Update Modal/Section (if order selected) -->
    <c:if test="${not empty selectedOrder}">
        <div style="background-color: var(--bg-primary); border: 1px solid var(--border-color-dark); padding: 30px;">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); padding-bottom: 15px; margin-bottom: 20px;">
                <h3 style="font-size: 15px; font-weight: 700; text-transform: uppercase;">
                    Chi Tiết Đơn Hàng: <c:out value="${selectedOrder.orderCode}"/>
                </h3>
                <a href="${pageContext.request.contextPath}/admin/orders" style="font-size: 12px; text-decoration: underline; color: #000; font-weight: 600;">Đóng lại</a>
            </div>

            <div style="display: flex; gap: 50px; flex-wrap: wrap; margin-bottom: 30px;">
                <!-- Left: Order Info & Shipping -->
                <div style="flex: 1; min-width: 300px;">
                    <h4 style="font-size: 13px; font-weight: 700; text-transform: uppercase; margin-bottom: 15px;">Thông Tin Giao Hàng</h4>
                    <p style="margin-bottom: 8px; font-size: 13px;">Khách hàng: <strong><c:out value="${selectedOrder.fullName}"/></strong></p>
                    <p style="margin-bottom: 8px; font-size: 13px;">Số điện thoại: <strong><c:out value="${selectedOrder.phone}"/></strong></p>
                    <p style="margin-bottom: 8px; font-size: 13px;">Địa chỉ nhận hàng: <strong><c:out value="${selectedOrder.address}"/></strong></p>
                    <p style="margin-bottom: 8px; font-size: 13px;">Ghi chú: <c:out value="${selectedOrder.notes}"/></p>
                    <p style="margin-bottom: 8px; font-size: 13px;">Phương thức thanh toán: <strong>${selectedOrder.paymentMethod == 'BANK_TRANSFER' ? 'Chuyển khoản' : 'COD'}</strong></p>
                    <p style="margin-bottom: 8px; font-size: 13px;">Thời gian đặt: <fmt:formatDate value="${selectedOrder.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                </div>

                <!-- Right: Status Update Form -->
                <div style="flex: 1; min-width: 300px; border-left: 1px solid var(--border-color); padding-left: 40px;">
                    <h4 style="font-size: 13px; font-weight: 700; text-transform: uppercase; margin-bottom: 15px;">Cập Nhật Trạng Thái</h4>
                    
                    <form action="${pageContext.request.contextPath}/admin/orders" method="POST">
                        <input type="hidden" name="action" value="updateStatus">
                        <input type="hidden" name="id" value="${selectedOrder.id}">

                        <div class="form-group">
                            <label for="status">Trạng Thái Giao Hàng</label>
                            <select id="status" name="status" style="width: 100%;">
                                <option value="PENDING" ${selectedOrder.status == 'PENDING' ? 'selected' : ''}>Chờ xác nhận (PENDING)</option>
                                <option value="CONFIRMED" ${selectedOrder.status == 'CONFIRMED' ? 'selected' : ''}>Đã xác nhận (CONFIRMED)</option>
                                <option value="PROCESSING" ${selectedOrder.status == 'PROCESSING' ? 'selected' : ''}>Đang xử lý (PROCESSING)</option>
                                <option value="SHIPPING" ${selectedOrder.status == 'SHIPPING' ? 'selected' : ''}>Đang giao (SHIPPING)</option>
                                <option value="DELIVERED" ${selectedOrder.status == 'DELIVERED' ? 'selected' : ''}>Đã giao (DELIVERED)</option>
                                <option value="CANCELLED" ${selectedOrder.status == 'CANCELLED' ? 'selected' : ''}>Đã hủy (CANCELLED)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="paymentStatus">Trạng Thái Thanh Toán</label>
                            <select id="paymentStatus" name="paymentStatus" style="width: 100%;">
                                <option value="UNPAID" ${selectedOrder.paymentStatus == 'UNPAID' ? 'selected' : ''}>Chưa thanh toán (UNPAID)</option>
                                <option value="PAID" ${selectedOrder.paymentStatus == 'PAID' ? 'selected' : ''}>Đã thanh toán (PAID)</option>
                            </select>
                        </div>

                        <button type="submit" class="btn btn-dark" style="width: 100%; margin-top: 10px;">Lưu Thay Đổi</button>
                    </form>
                </div>
            </div>

            <!-- Items Details Table -->
            <h4 style="font-size: 13px; font-weight: 700; text-transform: uppercase; margin-bottom: 15px;">Danh Sách Sản Phẩm Đặt</h4>
            <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                <thead>
                    <tr style="border-bottom: 1px solid var(--border-color-dark); font-weight: 700; text-align: left;">
                        <th style="padding: 10px 0;">Sản phẩm</th>
                        <th style="padding: 10px 0; text-align: center;">Kích cỡ / Màu</th>
                        <th style="padding: 10px 0; text-align: center;">Số lượng</th>
                        <th style="padding: 10px 0; text-align: right;">Đơn giá</th>
                        <th style="padding: 10px 0; text-align: right;">Tổng giá</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${selectedOrder.items}">
                        <tr style="border-bottom: 1px solid var(--border-color);">
                            <td style="padding: 12px 0;"><c:out value="${item.productName}"/></td>
                            <td style="padding: 12px 0; text-align: center;"><c:out value="${item.size}"/> / <c:out value="${item.color}"/></td>
                            <td style="padding: 12px 0; text-align: center;">${item.quantity}</td>
                            <td style="padding: 12px 0; text-align: right;">
                                <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </td>
                            <td style="padding: 12px 0; text-align: right; font-weight: 600;">
                                <fmt:formatNumber value="${item.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div style="text-align: right; margin-top: 25px; font-size: 13px;">
                <p style="margin-bottom: 5px;">Tạm tính: <strong><fmt:formatNumber value="${selectedOrder.totalAmount + selectedOrder.discountAmount - selectedOrder.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></strong></p>
                <p style="margin-bottom: 5px; color: #666;">Giảm giá: <strong>-<fmt:formatNumber value="${selectedOrder.discountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></strong></p>
                <p style="font-size: 15px; font-weight: 700; margin-top: 10px;">Tổng thanh toán: <strong><fmt:formatNumber value="${selectedOrder.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></strong></p>
            </div>
        </div>
    </c:if>

<jsp:include page="layout_footer.jsp" />

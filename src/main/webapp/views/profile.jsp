<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout/header.jsp">
    <jsp:param name="pageTitle" value="Trendify - Hồ Sơ Cá Nhân" />
</jsp:include>

<main>
    <c:if test="${not empty sessionScope.profileSuccess}">
        <div class="alert alert-success">
            <span><c:out value="${sessionScope.profileSuccess}"/></span>
            <button onclick="this.parentElement.style.display='none'" style="background:none; border:none; cursor:pointer; font-weight:bold; color:inherit;">[Đóng]</button>
        </div>
        <% session.removeAttribute("profileSuccess"); %>
    </c:if>
    <c:if test="${not empty sessionScope.profileError}">
        <div class="alert alert-danger">
            <span><c:out value="${sessionScope.profileError}"/></span>
            <button onclick="this.parentElement.style.display='none'" style="background:none; border:none; cursor:pointer; font-weight:bold; color:inherit;">[Đóng]</button>
        </div>
        <% session.removeAttribute("profileError"); %>
    </c:if>

    <div style="display: flex; gap: 50px; flex-wrap: wrap;">
        <!-- Left: Edit Profile Info -->
        <div style="flex: 1; min-width: 350px;">
            <h3 style="font-size: 16px; font-weight: 700; text-transform: uppercase; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                Thông Tin Cá Nhân
            </h3>

            <form action="${pageContext.request.contextPath}/profile" method="POST">
                <input type="hidden" name="action" value="updateProfile">

                <div class="form-group">
                    <label>Tên đăng nhập</label>
                    <input type="text" value="${sessionScope.currentUser.username}" disabled style="background-color: var(--bg-secondary); width: 100%;">
                </div>

                <div class="form-group">
                    <label for="fullName">Họ và Tên *</label>
                    <input type="text" id="fullName" name="fullName" value="<c:out value="${sessionScope.currentUser.fullName}"/>" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email" value="<c:out value="${sessionScope.currentUser.email}"/>" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="phone">Số Điện Thoại</label>
                    <input type="tel" id="phone" name="phone" value="<c:out value="${sessionScope.currentUser.phone}"/>" style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="address">Địa Chỉ Nhận Hàng Mặc Định</label>
                    <input type="text" id="address" name="address" value="<c:out value="${sessionScope.currentUser.address}"/>" style="width: 100%;">
                </div>

                <button type="submit" class="btn btn-dark" style="width: 100%; margin-top: 10px;">Cập Nhật Hồ Sơ</button>
            </form>

            <!-- Change Password -->
            <h3 style="font-size: 16px; font-weight: 700; text-transform: uppercase; margin-top: 40px; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                Đổi Mật Khẩu
            </h3>

            <form action="${pageContext.request.contextPath}/profile" method="POST">
                <input type="hidden" name="action" value="changePassword">

                <div class="form-group">
                    <label for="oldPassword">Mật khẩu cũ *</label>
                    <input type="password" id="oldPassword" name="oldPassword" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="newPassword">Mật khẩu mới *</label>
                    <input type="password" id="newPassword" name="newPassword" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu mới *</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required style="width: 100%;">
                </div>

                <button type="submit" class="btn btn-light" style="width: 100%; margin-top: 10px;">Thay Đổi Mật Khẩu</button>
            </form>
        </div>

        <!-- Right: Order History -->
        <div style="flex: 2; min-width: 500px;">
            <h3 style="font-size: 16px; font-weight: 700; text-transform: uppercase; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                Lịch Sử Đơn Hàng
            </h3>

            <c:choose>
                <c:when test="${not empty orders}">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Mã Đơn Hàng</th>
                                <th>Ngày Mua</th>
                                <th>Tổng Tiền</th>
                                <th>Thanh Toán</th>
                                <th>Vận Chuyển</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${orders}">
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/profile?action=orderDetail&code=${o.orderCode}" style="font-weight: 600; text-decoration: underline;">
                                            <c:out value="${o.orderCode}"/>
                                        </a>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
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
                                                <c:when test="${o.status == 'SHIPPING'}">Đang giao hàng</c:when>
                                                <c:when test="${o.status == 'DELIVERED'}">Đã giao hàng</c:when>
                                                <c:when test="${o.status == 'CANCELLED'}">Đã hủy</c:when>
                                            </c:choose>
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div style="padding: 50px; text-align: center; border: 1px dashed var(--border-color); color: var(--text-secondary);">
                        Bạn chưa thực hiện giao dịch mua hàng nào.
                    </div>
                </c:otherwise>
            </c:choose>
            
            <!-- Order Details Section if selected -->
            <c:if test="${not empty selectedOrder}">
                <div style="border: 1px solid var(--border-color-dark); padding: 30px; margin-top: 40px; background-color: var(--bg-secondary);">
                    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); padding-bottom: 15px; margin-bottom: 20px;">
                        <h4 style="font-size: 15px; font-weight: 700; text-transform: uppercase;">
                            Chi tiết đơn hàng: <c:out value="${selectedOrder.orderCode}"/>
                        </h4>
                        <a href="${pageContext.request.contextPath}/profile" style="font-size: 12px; text-decoration: underline;">Đóng lại</a>
                    </div>
                    
                    <div style="font-size: 13px; margin-bottom: 20px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div>
                            <p style="margin-bottom: 5px;">Người nhận: <strong><c:out value="${selectedOrder.fullName}"/></strong></p>
                            <p style="margin-bottom: 5px;">Số điện thoại: <strong><c:out value="${selectedOrder.phone}"/></strong></p>
                            <p style="margin-bottom: 5px;">Địa chỉ nhận: <strong><c:out value="${selectedOrder.address}"/></strong></p>
                        </div>
                        <div>
                            <p style="margin-bottom: 5px;">Phương thức thanh toán: 
                                <strong>${selectedOrder.paymentMethod == 'BANK_TRANSFER' ? 'Chuyển khoản ngân hàng' : 'COD'}</strong>
                            </p>
                            <p style="margin-bottom: 5px;">Ghi chú: <c:out value="${selectedOrder.notes}"/></p>
                            <p style="margin-bottom: 5px;">Thời gian đặt: <fmt:formatDate value="${selectedOrder.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                        </div>
                    </div>

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

                    <div style="text-align: right; margin-top: 20px; font-size: 13px;">
                        <p style="margin-bottom: 5px;">Tạm tính: <strong><fmt:formatNumber value="${selectedOrder.totalAmount + selectedOrder.discountAmount - selectedOrder.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></strong></p>
                        <p style="margin-bottom: 5px; color: #666;">Giảm giá: <strong>-<fmt:formatNumber value="${selectedOrder.discountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></strong></p>
                        <p style="font-size: 15px; font-weight: 700; margin-top: 10px;">Tổng thanh toán: <strong><fmt:formatNumber value="${selectedOrder.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></strong></p>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</main>

<jsp:include page="layout/footer.jsp" />

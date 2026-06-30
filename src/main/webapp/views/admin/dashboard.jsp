<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout.jsp">
    <jsp:param name="pageTitle" value="Trendify Admin - Thống Kê" />
    <jsp:param name="pageHeader" value="Tổng Quan & Báo Cáo Doanh Thu" />
    <jsp:param name="activeNav" value="dashboard" />
</jsp:include>

    <!-- KPI Cards Grid -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-label">Tổng Doanh Thu</div>
            <div class="kpi-value">
                <fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Tổng Đơn Hàng</div>
            <div class="kpi-value">${totalOrders}</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Tổng Sản Phẩm</div>
            <div class="kpi-value">${totalProducts}</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Người Dùng</div>
            <div class="kpi-value">${totalUsers}</div>
        </div>
    </div>

    <!-- Revenue Chart Area (SVG Representation) -->
    <div style="background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px; margin-bottom: 40px;">
        <h3 style="font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 25px;">Biểu Đồ Doanh Thu Các Đơn Hàng Mới Nhất</h3>
        
        <div style="display: flex; flex-direction: column; gap: 15px; border-left: 1px solid var(--border-color-dark); border-bottom: 1px solid var(--border-color-dark); padding: 20px 10px; min-height: 250px; justify-content: flex-end;">
            <c:choose>
                <c:when test="${not empty chartOrders}">
                    <div style="display: flex; align-items: flex-end; justify-content: space-around; height: 180px; width: 100%;">
                        <c:forEach var="o" items="${chartOrders}">
                            <!-- Calculate height percentage: (amount / maxAmount) * 150 -->
                            <c:set var="barHeight" value="${(o.totalAmount / maxOrderAmount) * 150}"/>
                            <c:if test="${barHeight < 10}">
                                <c:set var="barHeight" value="10"/>
                            </c:if>
                            
                            <div style="display: flex; flex-direction: column; align-items: center; width: 8%;">
                                <div style="font-size: 10px; font-weight: 600; margin-bottom: 5px;">
                                    <fmt:formatNumber value="${o.totalAmount / 1000}" maxFractionDigits="0"/>k
                                </div>
                                <div style="background-color: var(--bg-dark); width: 100%; height: ${barHeight}px; transition: var(--transition);" 
                                     title="Mã đơn: ${o.orderCode} - <fmt:formatNumber value='${o.totalAmount}' maxFractionDigits='0'/> đ">
                                </div>
                                <div style="font-size: 10px; color: var(--text-secondary); margin-top: 8px; text-transform: uppercase; font-weight: 500; text-align: center; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 60px;">
                                    ${o.orderCode}
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="text-align: center; padding: 50px; color: var(--text-secondary); width: 100%;">
                        Chưa có dữ liệu đơn hàng để thống kê biểu đồ.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Recent Orders Table -->
    <div style="background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px;">
        <h3 style="font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px;">Các Đơn Hàng Mới Nhất</h3>
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Mã Đơn Hàng</th>
                    <th>Người Nhận</th>
                    <th>Ngày Đặt</th>
                    <th>Tổng Tiền</th>
                    <th>Thanh Toán</th>
                    <th>Trạng Thái</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="o" items="${recentOrdersList}">
                    <tr>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/orders?action=detail&id=${o.id}" style="font-weight: 600; text-decoration: underline;">
                                <c:out value="${o.orderCode}"/>
                            </a>
                        </td>
                        <td><c:out value="${o.fullName}"/></td>
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
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

<jsp:include page="layout_footer.jsp" />

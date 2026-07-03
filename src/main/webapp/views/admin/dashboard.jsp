<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout.jsp">
    <jsp:param name="pageTitle" value="Trendify Admin - Thống Kê" />
    <jsp:param name="pageHeader" value="Tổng Quan & Báo Cáo Doanh Thu" />
    <jsp:param name="activeNav" value="dashboard" />
</jsp:include>
    <!-- BỘ LỌC THỐNG KÊ CHI TIẾT -->
    <div style="background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 25px; margin-bottom: 30px;">
        <h3 style="font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px; color: var(--text-primary);">
            Bộ Lọc Thống Kê Chi Tiết
        </h3>
        <form method="get" action="${pageContext.request.contextPath}/admin/dashboard" style="display: flex; flex-wrap: wrap; gap: 15px; align-items: flex-end;">
            
            <!-- Lọc theo nhân viên -->
            <div style="display: flex; flex-direction: column; gap: 5px; flex: 2; min-width: 220px;">
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-secondary); letter-spacing: 0.5px;">Nhân viên chốt đơn</label>
                <select name="employeeId" style="width: 100%; height: 40px; border: 1px solid var(--border-color); background-color: var(--bg-primary); padding: 0 12px; font-size: 13px; color: var(--text-primary); transition: var(--transition);">
                    <option value="">-- Tất cả nhân viên --</option>
                    <c:forEach var="staff" items="${staffList}">
                        <option value="${staff.id}" ${staff.id == selectedEmployeeId ? 'selected' : ''}>
                            ${staff.fullName} (${staff.role})
                        </option>
                    </c:forEach>
                </select>
            </div>
            
            <!-- Lọc theo khoảng ngày -->
            <div style="display: flex; flex-direction: column; gap: 5px; flex: 1.5; min-width: 160px;">
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-secondary); letter-spacing: 0.5px;">Từ ngày</label>
                <input type="date" name="startDate" value="${selectedStartDate}" style="width: 100%; height: 40px; border: 1px solid var(--border-color); background-color: var(--bg-primary); padding: 0 12px; font-size: 13px; color: var(--text-primary);" />
            </div>
            <div style="display: flex; flex-direction: column; gap: 5px; flex: 1.5; min-width: 160px;">
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-secondary); letter-spacing: 0.5px;">Đến ngày</label>
                <input type="date" name="endDate" value="${selectedEndDate}" style="width: 100%; height: 40px; border: 1px solid var(--border-color); background-color: var(--bg-primary); padding: 0 12px; font-size: 13px; color: var(--text-primary);" />
            </div>
            
            <!-- Lọc theo tháng/năm -->
            <div style="display: flex; flex-direction: column; gap: 5px; width: 90px;">
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-secondary); letter-spacing: 0.5px;">Tháng</label>
                <select name="month" style="width: 100%; height: 40px; border: 1px solid var(--border-color); background-color: var(--bg-primary); padding: 0 12px; font-size: 13px; color: var(--text-primary);">
                    <option value="">--</option>
                    <c:forEach var="m" begin="1" end="12">
                        <option value="${m}" ${m == selectedMonth ? 'selected' : ''}>${m}</option>
                    </c:forEach>
                </select>
            </div>
            <div style="display: flex; flex-direction: column; gap: 5px; width: 100px;">
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-secondary); letter-spacing: 0.5px;">Năm</label>
                <select name="year" style="width: 100%; height: 40px; border: 1px solid var(--border-color); background-color: var(--bg-primary); padding: 0 12px; font-size: 13px; color: var(--text-primary);">
                    <option value="">--</option>
                    <option value="2026" ${selectedYear == 2026 ? 'selected' : ''}>2026</option>
                    <option value="2025" ${selectedYear == 2025 ? 'selected' : ''}>2025</option>
                    <option value="2027" ${selectedYear == 2027 ? 'selected' : ''}>2027</option>
                </select>
            </div>
            
            <!-- Nút hành động -->
            <div style="display: flex; gap: 10px; min-width: 180px;">
                <button type="submit" class="admin-btn-primary" style="height: 40px; padding: 0 25px; font-size: 13px; font-weight: 700; cursor: pointer; background-color: var(--text-primary); color: var(--bg-primary); border: none;">ÁP DỤNG</button>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-btn-secondary" style="height: 40px; line-height: 38px; display: inline-block; text-align: center; text-decoration: none; padding: 0 18px; border: 1px solid var(--border-color); font-size: 13px; font-weight: 600; color: var(--text-primary); transition: var(--transition);">LÀM MỚI</a>
            </div>
        </form>
    </div>

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
    <!-- BÁO CÁO DOANH SỐ NHÂN VIÊN -->
    <div style="background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px; margin-bottom: 40px;">
        <h3 style="font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px;">Doanh Số Đóng Góp Theo Nhân Viên</h3>
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Tên Nhân Viên</th>
                    <th>Tổng Doanh Thu Đã Chốt</th>
                    <th>Số Đơn Hàng Thành Công</th>
                    <th>Tỷ Lệ Đóng Góp</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty employeeRankings}">
                        <!-- Tìm doanh thu lớn nhất của nhân viên để làm mốc tính % tỷ lệ đóng góp tương đối -->
                        <c:set var="maxEmpRev" value="1.0" />
                        <c:forEach var="rank" items="${employeeRankings}">
                            <c:if var="isGreater" test="${rank[1] > maxEmpRev}">
                                <c:set var="maxEmpRev" value="${rank[1]}" />
                            </c:if>
                        </c:forEach>
                        
                        <c:forEach var="rank" items="${employeeRankings}">
                            <!-- Tính tỷ lệ chiều rộng thanh đo (tối đa 100%) -->
                            <c:set var="barPercent" value="${(rank[1] / maxEmpRev) * 100}" />
                            <tr>
                                <td style="font-weight: 600;"><c:out value="${rank[0]}"/></td>
                                <td style="font-weight: 700; color: var(--text-primary);">
                                    <fmt:formatNumber value="${rank[1]}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </td>
                                <td style="font-weight: 600;">${rank[2]} đơn</td>
                                <td style="width: 35%;">
                                    <div style="display: flex; align-items: center; gap: 10px;">
                                        <div style="flex-grow: 1; background-color: var(--border-color); height: 8px; border-radius: 4px; overflow: hidden;">
                                            <div style="background-color: var(--bg-dark); width: ${barPercent}%; height: 100%; border-radius: 4px;"></div>
                                        </div>
                                        <span style="font-size: 11px; font-weight: 700; min-width: 35px; text-align: right;">
                                            <fmt:formatNumber value="${barPercent}" maxFractionDigits="0"/>%
                                        </span>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="4" style="text-align: center; color: var(--text-secondary); padding: 30px;">
                                Chưa ghi nhận doanh số nhân viên trong kỳ lọc này.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
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

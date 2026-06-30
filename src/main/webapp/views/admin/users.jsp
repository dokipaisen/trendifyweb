<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout.jsp">
    <jsp:param name="pageTitle" value="Trendify Admin - Người Dùng" />
    <jsp:param name="pageHeader" value="Quản Lý Tài Khoản & Người Dùng" />
    <jsp:param name="activeNav" value="users" />
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

    <!-- Users Table -->
    <div style="background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px;">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Tên đăng nhập</th>
                    <th>Họ và Tên</th>
                    <th>Email</th>
                    <th>Điện Thoại</th>
                    <th>Vai Trò</th>
                    <th>Trạng Thái</th>
                    <th style="text-align: right; width: 220px;">Thay Đổi Hành Động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${users}">
                    <tr>
                        <td style="font-weight: 600;"><c:out value="${u.username}"/></td>
                        <td><c:out value="${u.fullName}"/></td>
                        <td><c:out value="${u.email}"/></td>
                        <td><c:out value="${u.phone}"/></td>
                        <td>
                            <span class="status-badge ${u.role == 'ADMIN' ? 'status-success' : (u.role == 'EMPLOYEE' ? 'status-pending' : '')}" style="border-color: #333;">
                                <c:out value="${u.role}"/>
                            </span>
                        </td>
                        <td>
                            <span class="status-badge ${u.status == 'ACTIVE' ? 'status-success' : 'status-danger'}">
                                ${u.status == 'ACTIVE' ? 'Hoạt động' : 'Bị khóa'}
                            </span>
                        </td>
                        <td style="text-align: right;">
                            <!-- Prevent editing self to avoid locking self out of admin -->
                            <c:choose>
                                <c:when test="${u.id == sessionScope.currentUser.id}">
                                    <span style="font-size: 11px; color: var(--text-muted); font-style: italic;">Tài khoản của bạn</span>
                                </c:when>
                                <c:otherwise>
                                    <form action="${pageContext.request.contextPath}/admin/users" method="POST" style="display: inline-flex; gap: 5px;">
                                        <input type="hidden" name="id" value="${u.id}">
                                        
                                        <!-- Role selection -->
                                        <select name="role" style="padding: 4px 8px; font-size: 11px;" onchange="this.form.submit()">
                                            <option value="CUSTOMER" ${u.role == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                                            <option value="EMPLOYEE" ${u.role == 'EMPLOYEE' ? 'selected' : ''}>EMPLOYEE</option>
                                            <option value="ADMIN" ${u.role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                                        </select>
                                        
                                        <!-- Status selection -->
                                        <select name="status" style="padding: 4px 8px; font-size: 11px;" onchange="this.form.submit()">
                                            <option value="ACTIVE" ${u.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                            <option value="INACTIVE" ${u.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                        </select>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

<jsp:include page="layout_footer.jsp" />

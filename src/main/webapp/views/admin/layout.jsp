<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.pageTitle != null ? param.pageTitle : 'Trendify Admin Portal'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=3">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body>

<div class="admin-container">
    <!-- Admin Sidebar -->
    <aside class="admin-sidebar">
        <div class="logo">
            <a href="${pageContext.request.contextPath}/admin/dashboard" style="color: #fff; font-weight: 800; letter-spacing: 2px;">TDF ADMIN</a>
            <div style="font-size: 11px; color: var(--text-muted); margin-top: 5px; text-transform: uppercase; font-weight: 600;">
                Quyền: <c:out value="${sessionScope.currentUser.role}"/>
            </div>
        </div>

        <nav class="admin-nav-links">
            <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-nav-link ${param.activeNav == 'dashboard' ? 'active' : ''}">Thống Kê Doanh Thu</a>
            </c:if>
            <a href="${pageContext.request.contextPath}/admin/products" class="admin-nav-link ${param.activeNav == 'products' ? 'active' : ''}">Quản Lý Sản Phẩm</a>
            <a href="${pageContext.request.contextPath}/admin/categories" class="admin-nav-link ${param.activeNav == 'categories' ? 'active' : ''}">Quản Lý Danh Mục</a>
            <a href="${pageContext.request.contextPath}/admin/orders" class="admin-nav-link ${param.activeNav == 'orders' ? 'active' : ''}">Quản Lý Đơn Hàng</a>
            <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin/promotions" class="admin-nav-link ${param.activeNav == 'promotions' ? 'active' : ''}">Quản Lý Voucher</a>
                <a href="${pageContext.request.contextPath}/admin/users" class="admin-nav-link ${param.activeNav == 'users' ? 'active' : ''}">Quản Lý Người Dùng</a>
            </c:if>
            
            <div style="border-top: 1px solid rgba(255,255,255,0.1); margin-top: 30px; padding-top: 20px;">
                <a href="${pageContext.request.contextPath}/home" class="admin-nav-link">Xem Trang Chủ Cửa Hàng</a>
                <a href="${pageContext.request.contextPath}/login?action=logout" class="admin-nav-link" style="text-decoration: underline;">Đăng Xuất</a>
            </div>
        </nav>
    </aside>

    <!-- Admin Main Body Wrapper -->
    <div class="admin-main">
        <div class="admin-header">
            <h1>${param.pageHeader != null ? param.pageHeader : 'Báo Cáo & Thống Kê'}</h1>
            <div style="font-size: 13px;">
                Xin chào, <strong><c:out value="${sessionScope.currentUser.fullName}"/></strong>
            </div>
        </div>

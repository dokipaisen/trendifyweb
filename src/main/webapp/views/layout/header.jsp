<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.pageTitle != null ? param.pageTitle : 'Trendify - Premium Minimalist Fashion'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=3">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body>

<header>
    <div class="nav-container">
        <a href="${pageContext.request.contextPath}/home" class="logo">TRENDIFY</a>
        
        <nav class="nav-links">
            <a href="${pageContext.request.contextPath}/home">Trang Chủ</a>
            <a href="${pageContext.request.contextPath}/shop">Danh Mục</a>
            <a href="${pageContext.request.contextPath}/shop">Sale</a>
            <a href="${pageContext.request.contextPath}/support">Về Chúng Tôi</a>
        </nav>

        <div class="header-search">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            <form action="${pageContext.request.contextPath}/shop" method="get" style="width: 100%;">
                <input type="text" name="keyword" placeholder="Tìm kiếm sản phẩm..." value="<c:out value="${param.keyword}"/>">
            </form>
        </div>
        
        <div class="nav-icons">
            <a href="#" onclick="alert('Tính năng Danh sách yêu thích sẽ được cập nhật sớm!'); return false;" title="Danh sách yêu thích">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path></svg>
            </a>
            
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    <a href="${pageContext.request.contextPath}/profile" title="Hồ sơ cá nhân (${sessionScope.currentUser.fullName})">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                    </a>
                    <c:if test="${sessionScope.currentUser.role == 'ADMIN' or sessionScope.currentUser.role == 'EMPLOYEE'}">
                        <a href="${pageContext.request.contextPath}/admin/dashboard" title="Trang quản trị" style="font-size: 10px; font-weight: 700; border: 1px solid var(--text-primary); padding: 2px 6px; border-radius: 4px; text-transform: uppercase;">Admin</a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/login?action=logout" title="Đăng xuất" style="font-size: 11px; text-decoration: underline;">Đăng Xuất</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" title="Đăng nhập / Đăng ký">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                    </a>
                </c:otherwise>
            </c:choose>
            
            <a href="${pageContext.request.contextPath}/cart" title="Giỏ hàng">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                <c:if test="${not empty sessionScope.cartSize and sessionScope.cartSize > 0}">
                    <span class="cart-badge">${sessionScope.cartSize}</span>
                </c:if>
            </a>
        </div>
    </div>
</header>

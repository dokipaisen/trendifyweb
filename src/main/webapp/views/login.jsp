<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trendify - Đăng Nhập</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=3">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body style="overflow: hidden;">

<div class="split-container">
    <!-- Left Screen (Dark Branding Block) -->
    <div class="split-left">
        <div class="split-left-content">
            <a href="${pageContext.request.contextPath}/home" style="font-size: 24px; font-weight: 800; letter-spacing: 3px; display: block; margin-bottom: 50px;">TRENDIFY</a>
            <h1>Mua sắm thời trang<br>không giới hạn.<br>Mọi lúc, mọi nơi.</h1>
            <p style="color: var(--text-muted); font-size: 14px; max-width: 320px; line-height: 1.6;">Trải nghiệm những bộ sưu tập cao cấp với chất liệu tự nhiên và phong cách thiết kế tối giản.</p>
        </div>
    </div>

    <!-- Right Screen (White Login Form Block) -->
    <div class="split-right">
        <div style="margin-bottom: 40px;">
            <h2 style="font-size: 24px; font-weight: 700; text-transform: uppercase; margin-bottom: 8px;">Đăng Nhập</h2>
            <p style="font-size: 13px; color: var(--text-secondary);">Điền thông tin tài khoản của bạn để tiếp tục.</p>
        </div>

        <c:if test="${not empty sessionScope.authError}">
            <div class="alert alert-danger" style="border-color: #999; margin-bottom: 20px;">
                <span style="color: #666;"><c:out value="${sessionScope.authError}"/></span>
            </div>
            <% session.removeAttribute("authError"); %>
        </c:if>
        <c:if test="${not empty sessionScope.authSuccess}">
            <div class="alert alert-success" style="margin-bottom: 20px;">
                <span><c:out value="${sessionScope.authSuccess}"/></span>
            </div>
            <% session.removeAttribute("authSuccess"); %>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="POST">
            <input type="hidden" name="redirect" value="<c:out value="${param.redirect}"/>">
            
            <div class="form-group">
                <label for="username">Tên đăng nhập</label>
                <input type="text" id="username" name="username" required>
            </div>

            <div class="form-group">
                <label for="password">Mật khẩu</label>
                <input type="password" id="password" name="password" required>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-dark">Đăng Nhập</button>
            </div>
        </form>

        <div class="form-footer-text">
            Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a>
        </div>
        
        <div style="margin-top: 40px; text-align: center;">
            <a href="${pageContext.request.contextPath}/home" style="font-size: 12px; color: var(--text-secondary); text-decoration: underline;">Quay lại Trang chủ</a>
        </div>
    </div>
</div>

</body>
</html>

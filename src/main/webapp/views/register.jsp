<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trendify - Đăng Ký Tài Khoản</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=3">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body style="overflow-x: hidden;">

<div class="split-container" style="min-height: 100vh;">
    <!-- Left Screen (Dark Branding Block) -->
    <div class="split-left">
        <div class="split-left-content">
            <a href="${pageContext.request.contextPath}/home" style="font-size: 24px; font-weight: 800; letter-spacing: 3px; display: block; margin-bottom: 50px;">TRENDIFY</a>
            <h1>Tham gia với chúng tôi.<br>Hoàn toàn miễn phí.<br>Nhận ngay ưu đãi.</h1>
            <p style="color: var(--text-muted); font-size: 14px; max-width: 320px; line-height: 1.6;">Trở thành thành viên để được tích điểm mua hàng, nhận các chương trình khuyến mãi và quản lý đơn hàng thông minh.</p>
        </div>
    </div>

    <!-- Right Screen (White Register Form Block) -->
    <div class="split-right" style="width: 520px; padding: 40px; justify-content: flex-start; overflow-y: auto;">
        <div style="margin-bottom: 25px; margin-top: 30px;">
            <h2 style="font-size: 22px; font-weight: 700; text-transform: uppercase; margin-bottom: 8px;">Đăng Ký Tài Khoản</h2>
            <p style="font-size: 13px; color: var(--text-secondary);">Lập tài khoản mới để bắt đầu mua sắm.</p>
        </div>

        <c:if test="${not empty sessionScope.authError}">
            <div class="alert alert-danger" style="border-color: #999; margin-bottom: 20px;">
                <span style="color: #666;"><c:out value="${sessionScope.authError}"/></span>
            </div>
            <% session.removeAttribute("authError"); %>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="POST">
            <div class="form-group">
                <label for="username">Tên đăng nhập *</label>
                <input type="text" id="username" name="username" required>
            </div>

            <div class="form-group">
                <label for="password">Mật khẩu *</label>
                <input type="password" id="password" name="password" required>
            </div>

            <div class="form-group">
                <label for="fullName">Họ và Tên *</label>
                <input type="text" id="fullName" name="fullName" required>
            </div>

            <div class="form-group">
                <label for="email">Email *</label>
                <input type="email" id="email" name="email" required>
            </div>

            <div class="form-group">
                <label for="phone">Số điện thoại</label>
                <input type="tel" id="phone" name="phone">
            </div>

            <div class="form-group">
                <label for="address">Địa chỉ giao hàng mặc định</label>
                <input type="text" id="address" name="address">
            </div>

            <div class="form-actions" style="margin-top: 25px;">
                <button type="submit" class="btn btn-dark">Đăng Ký Tài Khoản</button>
            </div>
        </form>

        <div class="form-footer-text" style="margin-bottom: 30px;">
            Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập ngay</a>
        </div>
    </div>
</div>

</body>
</html>

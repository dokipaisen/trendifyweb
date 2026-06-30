<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout/header.jsp">
    <jsp:param name="pageTitle" value="Trendify - Trang Chủ" />
</jsp:include>

<main>
    <!-- Split Hero Banner -->
    <div class="hero-split">
        <div class="hero-split-left">
            <div class="hero-tagline">BỘ SƯU TẬP 2026</div>
            <h1>Phong Cách<br>Định Nghĩa<br><span class="accent-word">Bạn</span></h1>
            <p>Khám phá nghệ thuật thời trang tối giản và thanh lịch từ Trendify. Nơi phom dáng hoàn hảo kết hợp cùng chất liệu thượng hạng vẽ nên chất riêng của bạn.</p>
            <div class="hero-buttons">
                <a href="${pageContext.request.contextPath}/shop" class="hero-btn-primary">MUA NGAY</a>
                <a href="${pageContext.request.contextPath}/shop" class="hero-link-secondary">
                    Xem bộ sưu tập
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-left: 2px;"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
                </a>
            </div>
        </div>
        <div class="hero-split-right">
            <img src="https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=1000" alt="Trendify Collection">
        </div>
    </div>

    <!-- Featured Products Section -->
    <div class="section-header">
        <div class="section-header-left">
            <h3 style="font-size: 10px; font-weight: 700; color: var(--text-secondary); letter-spacing: 2px; text-transform: uppercase; margin-bottom: 6px;">SUMMER FOR HIM</h3>
            <h2 style="font-size: 24px; font-weight: 700; margin: 0; letter-spacing: 0.5px;">Sản Phẩm Nổi Bật</h2>
        </div>
        <div class="section-header-right">
            <a href="${pageContext.request.contextPath}/shop">
                Xem tất cả
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-left: 2px;"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
            </a>
        </div>
    </div>
    
    <div class="product-grid">
        <c:forEach var="p" items="${featuredProducts}" begin="0" end="3">
            <div class="product-card" style="position: relative;">
                <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}">
                    <c:if test="${not empty p.originalPrice and p.originalPrice > p.price}">
                        <div class="product-badge-left">Sale</div>
                    </c:if>
                    <c:if test="${p.rating >= 4.8}">
                        <div class="product-badge-right">New</div>
                    </c:if>
                    <div class="product-image-wrapper">
                        <img src="${p.imageUrl}" alt="${p.name}">
                    </div>
                    <div class="product-info">
                        <div class="product-brand"><c:out value="${p.brand}"/></div>
                        <div class="product-name"><c:out value="${p.name}"/></div>
                        <div class="product-price-wrapper">
                            <span class="product-price">
                                <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </span>
                            <c:if test="${not empty p.originalPrice and p.originalPrice > p.price}">
                                <span class="product-original-price">
                                    <fmt:formatNumber value="${p.originalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </c:if>
                        </div>
                        <button class="product-card-btn" onclick="window.location.href='${pageContext.request.contextPath}/product/detail?id=${p.id}'; return false;">Thêm sản phẩm</button>
                    </div>
                </a>
            </div>
        </c:forEach>
    </div>

    <!-- Flash Sale Section -->
    <div class="flash-sale-section">
        <div class="flash-sale-container">
            <div class="section-header">
                <div class="section-header-left">
                    <h3>FLASH SALE</h3>
                    <h2>Khuyến Mãi Hôm Nay</h2>
                </div>
                <div class="section-header-right">
                    <a href="${pageContext.request.contextPath}/shop">
                        Tất cả các sản phẩm
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-left: 2px;"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
                    </a>
                </div>
            </div>
            
            <div class="product-grid">
                <c:forEach var="p" items="${featuredProducts}" begin="0" end="4">
                    <div class="product-card" style="position: relative;">
                        <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}">
                            <c:if test="${not empty p.originalPrice and p.originalPrice > p.price}">
                                <div class="product-badge-left">Sale</div>
                                <div class="product-badge-right" style="background-color: #ef4444; color: white;">-${100 - (p.price * 100 / p.originalPrice).intValue()}%</div>
                            </c:if>
                            <div class="product-image-wrapper">
                                <img src="${p.imageUrl}" alt="${p.name}">
                            </div>
                            <div class="product-info">
                                <div class="product-brand"><c:out value="${p.brand}"/></div>
                                <div class="product-name"><c:out value="${p.name}"/></div>
                                <div class="product-price-wrapper">
                                    <span class="product-price">
                                        <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>
                                    <c:if test="${not empty p.originalPrice and p.originalPrice > p.price}">
                                        <span class="product-original-price">
                                            <fmt:formatNumber value="${p.originalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </span>
                                    </c:if>
                                </div>
                                <button class="product-card-btn" onclick="window.location.href='${pageContext.request.contextPath}/product/detail?id=${p.id}'; return false;">Thêm sản phẩm</button>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- Twin Collection Banners -->
    <div class="collection-banners">
        <div class="collection-banner-card">
            <img src="https://images.unsplash.com/photo-1512436991641-6745cdb1723f?q=80&w=1000" alt="Men's Collection">
            <div class="collection-banner-content">
                <span>TIÊU ĐIỂM NAM</span>
                <h2>Bộ Sưu Tập Nam</h2>
                <a href="${pageContext.request.contextPath}/shop" class="collection-banner-btn">MUA NGAY</a>
            </div>
        </div>
        <div class="collection-banner-card">
            <img src="https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=1000" alt="Women's Collection">
            <div class="collection-banner-content">
                <span>TIÊU ĐIỂM NỮ</span>
                <h2>Bộ Sưu Tập Nữ</h2>
                <a href="${pageContext.request.contextPath}/shop" class="collection-banner-btn">MUA NGAY</a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="layout/footer.jsp" />

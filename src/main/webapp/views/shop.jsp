<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout/header.jsp">
    <jsp:param name="pageTitle" value="Trendify - Cửa Hàng" />
</jsp:include>

<main>
    <div class="shop-layout">
        <!-- Sidebar Filter -->
        <aside class="shop-sidebar">
            <form action="${pageContext.request.contextPath}/shop" method="GET" id="filterForm">
                <!-- Search -->
                <div class="filter-section">
                    <h3>Tìm Kiếm</h3>
                    <input type="text" name="keyword" value="<c:out value="${param.keyword}"/>" placeholder="Từ khóa..." style="width: 100%;">
                </div>

                <!-- Categories -->
                <div class="filter-section">
                    <h3>Danh Mục</h3>
                    <div class="filter-list">
                        <label class="filter-item">
                            <input type="radio" name="categoryId" value="" ${empty param.categoryId ? 'checked' : ''} onchange="this.form.submit()">
                            <span>Tất cả</span>
                        </label>
                        <c:forEach var="c" items="${categories}">
                            <label class="filter-item">
                                <input type="radio" name="categoryId" value="${c.id}" ${param.categoryId == c.id ? 'checked' : ''} onchange="this.form.submit()">
                                <span><c:out value="${c.name}"/></span>
                            </label>
                        </c:forEach>
                    </div>
                </div>

                <!-- Brands -->
                <div class="filter-section">
                    <h3>Thương Hiệu</h3>
                    <div class="filter-list">
                        <label class="filter-item">
                            <input type="radio" name="brand" value="" ${empty param.brand ? 'checked' : ''} onchange="this.form.submit()">
                            <span>Tất cả</span>
                        </label>
                        <c:forEach var="b" items="${brands}">
                            <label class="filter-item">
                                <input type="radio" name="brand" value="${b}" ${param.brand == b ? 'checked' : ''} onchange="this.form.submit()">
                                <span><c:out value="${b}"/></span>
                            </label>
                        </c:forEach>
                    </div>
                </div>

                <!-- Price range -->
                <div class="filter-section">
                    <h3>Khoảng Giá</h3>
                    <div class="price-range-inputs">
                        <input type="number" name="minPrice" value="<c:out value="${param.minPrice}"/>" placeholder="Từ">
                        <span>-</span>
                        <input type="number" name="maxPrice" value="<c:out value="${param.maxPrice}"/>" placeholder="Đến">
                    </div>
                    <button type="submit" class="btn btn-dark" style="width: 100%; margin-top: 15px; font-size: 12px; padding: 8px;">Áp Dụng</button>
                </div>
                
                <a href="${pageContext.request.contextPath}/shop" class="btn btn-light" style="width: 100%; font-size: 12px; padding: 8px; text-align: center;">Xóa Bộ Lọc</a>
            </form>
        </aside>

        <!-- Main Product Grid -->
        <section class="shop-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                <h2 style="font-size: 20px; font-weight: 700; text-transform: uppercase;">Danh Sách Sản Phẩm</h2>
                <span style="font-size: 13px; color: var(--text-secondary);">${products.size()} sản phẩm được tìm thấy</span>
            </div>

            <c:choose>
                <c:when test="${not empty products}">
                    <div class="product-grid">
                        <c:forEach var="p" items="${products}">
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
                </c:when>
                <c:otherwise>
                    <div style="text-align: center; padding: 80px 20px; border: 1px dashed var(--border-color); color: var(--text-secondary);">
                        <p>Không tìm thấy sản phẩm nào phù hợp với tiêu chí của bạn.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>

<jsp:include page="layout/footer.jsp" />

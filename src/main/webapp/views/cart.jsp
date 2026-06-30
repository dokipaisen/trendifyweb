<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout/header.jsp">
    <jsp:param name="pageTitle" value="Trendify - Giỏ Hàng" />
</jsp:include>

<main>
    <h2 class="section-title">Giỏ Hàng Của Bạn</h2>

    <c:if test="${not empty sessionScope.cartSuccess}">
        <div class="alert alert-success">
            <span><c:out value="${sessionScope.cartSuccess}"/></span>
            <button onclick="this.parentElement.style.display='none'" style="background:none; border:none; cursor:pointer; font-weight:bold; color:inherit;">[Đóng]</button>
        </div>
        <% session.removeAttribute("cartSuccess"); %>
    </c:if>
    <c:if test="${not empty sessionScope.cartError}">
        <div class="alert alert-danger">
            <span><c:out value="${sessionScope.cartError}"/></span>
            <button onclick="this.parentElement.style.display='none'" style="background:none; border:none; cursor:pointer; font-weight:bold; color:inherit;">[Đóng]</button>
        </div>
        <% session.removeAttribute("cartError"); %>
    </c:if>

    <c:choose>
        <c:when test="${not empty cartItems}">
            <div class="cart-layout">
                <!-- Cart Items Table -->
                <div class="cart-items-table">
                    <div class="cart-header-row">
                        <span>Sản Phẩm</span>
                        <span>Đơn Giá</span>
                        <span>Số Lượng</span>
                        <span>Tổng Cộng</span>
                        <span></span>
                    </div>

                    <c:forEach var="item" items="${cartItems}">
                        <div class="cart-item-row">
                            <!-- Product Cell -->
                            <div class="cart-product-cell">
                                <div class="cart-product-img">
                                    <img src="${item.productImageUrl}" alt="${item.productName}">
                                </div>
                                <div class="cart-product-info">
                                    <h4><c:out value="${item.productName}"/></h4>
                                    <p>Phân loại: <c:out value="${item.color}"/> / Kích cỡ: <c:out value="${item.size}"/></p>
                                    <p style="font-size: 11px; text-transform: uppercase;">Thương hiệu: <c:out value="${item.productBrand}"/></p>
                                </div>
                            </div>
                            
                            <!-- Price Cell -->
                            <div>
                                <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </div>

                            <!-- Quantity Cell -->
                            <div>
                                <form action="${pageContext.request.contextPath}/cart" method="POST" style="display: flex; gap: 5px; align-items: center;">
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="variantId" value="${item.variantId}">
                                    <input type="number" name="quantity" value="${item.quantity}" min="1" max="99" style="width: 60px; padding: 5px;">
                                    <button type="submit" class="btn btn-light" style="padding: 5px 8px; font-size: 11px; border-color: #ccc;">Lưu</button>
                                </form>
                            </div>

                            <!-- Total Cell -->
                            <div style="font-weight: 600;">
                                <fmt:formatNumber value="${item.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </div>

                            <!-- Remove Cell -->
                            <div>
                                <form action="${pageContext.request.contextPath}/cart" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa sản phẩm này?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="variantId" value="${item.variantId}">
                                    <button type="submit" style="background: none; border: none; cursor: pointer; color: var(--text-muted); font-size: 12px; text-decoration: underline;">Xóa</button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Order Summary Sidebar -->
                <div class="cart-summary">
                    <h3 style="font-size: 16px; font-weight: 700; text-transform: uppercase; margin-bottom: 25px; letter-spacing: 1px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                        Tóm Tắt Đơn Hàng
                    </h3>

                    <div class="summary-row">
                        <span>Tạm tính</span>
                        <span>
                            <fmt:formatNumber value="${cartSubtotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </span>
                    </div>

                    <c:if test="${not empty appliedVoucher}">
                        <div class="summary-row" style="color: #666;">
                            <span>Giảm giá (${appliedVoucher.code})</span>
                            <span>
                                -<fmt:formatNumber value="${discountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </span>
                        </div>
                    </c:if>

                    <div class="summary-row">
                        <span>Phí vận chuyển</span>
                        <span>Miễn phí</span>
                    </div>

                    <div class="summary-row total">
                        <span>Tổng cộng</span>
                        <span>
                            <fmt:formatNumber value="${cartTotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </span>
                    </div>

                    <!-- Voucher Input -->
                    <form action="${pageContext.request.contextPath}/cart" method="POST" style="margin-bottom: 25px;">
                        <input type="hidden" name="action" value="voucher">
                        <div style="display: flex; gap: 8px;">
                            <input type="text" name="voucherCode" placeholder="Mã khuyến mãi" value="${appliedVoucher != null ? appliedVoucher.code : ''}" style="flex-grow: 1; text-transform: uppercase;">
                            <button type="submit" class="btn btn-light" style="padding: 8px 14px;">Áp dụng</button>
                        </div>
                        <c:if test="${not empty appliedVoucher}">
                            <div style="font-size: 11px; margin-top: 5px; color: #666;">
                                <a href="${pageContext.request.contextPath}/cart?action=clearVoucher" style="text-decoration: underline;">Gỡ bỏ mã giảm giá</a>
                            </div>
                        </c:if>
                    </form>

                    <a href="${pageContext.request.contextPath}/checkout" class="btn btn-dark" style="width: 100%; text-align: center;">Thanh Toán Ngay</a>
                    
                    <div style="text-align: center; margin-top: 15px;">
                        <a href="${pageContext.request.contextPath}/shop" style="font-size: 12px; text-decoration: underline; color: var(--text-secondary);">Tiếp tục mua sắm</a>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div style="text-align: center; padding: 100px 20px; border: 1px dashed var(--border-color); color: var(--text-secondary);">
                <p style="margin-bottom: 20px;">Giỏ hàng của bạn đang trống.</p>
                <a href="${pageContext.request.contextPath}/shop" class="btn btn-dark">Mua Sắm Ngay</a>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<jsp:include page="layout/footer.jsp" />

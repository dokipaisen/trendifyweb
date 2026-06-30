<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout/header.jsp">
    <jsp:param name="pageTitle" value="Trendify - Thanh Toán" />
</jsp:include>

<main>
    <h2 class="section-title">Thanh Toán Đơn Hàng</h2>

    <c:if test="${not empty sessionScope.checkoutError}">
        <div class="alert alert-danger">
            <span><c:out value="${sessionScope.checkoutError}"/></span>
            <button onclick="this.parentElement.style.display='none'" style="background:none; border:none; cursor:pointer; font-weight:bold; color:inherit;">[Đóng]</button>
        </div>
        <% session.removeAttribute("checkoutError"); %>
    </c:if>

    <div class="cart-layout">
        <!-- Billing Details Form -->
        <div style="flex-grow: 1;">
            <h3 style="font-size: 16px; font-weight: 700; text-transform: uppercase; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                Thông Tin Giao Hàng
            </h3>

            <form action="${pageContext.request.contextPath}/checkout" method="POST" id="checkoutForm">
                <div class="form-group">
                    <label for="fullName">Họ và Tên *</label>
                    <input type="text" id="fullName" name="fullName" value="<c:out value="${sessionScope.currentUser.fullName}"/>" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="phone">Số Điện Thoại *</label>
                    <input type="tel" id="phone" name="phone" value="<c:out value="${sessionScope.currentUser.phone}"/>" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="address">Địa Chỉ Giao Hàng *</label>
                    <input type="text" id="address" name="address" value="<c:out value="${sessionScope.currentUser.address}"/>" required style="width: 100%;">
                </div>

                <div class="form-group">
                    <label for="notes">Ghi Chú</label>
                    <textarea id="notes" name="notes" rows="3" style="width: 100%; resize: vertical;" placeholder="Hướng dẫn giao hàng đặc biệt..."></textarea>
                </div>

                <!-- Payment Methods -->
                <h3 style="font-size: 16px; font-weight: 700; text-transform: uppercase; margin-top: 40px; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                    Phương Thức Thanh Toán
                </h3>

                <div class="filter-list" style="margin-bottom: 30px;">
                    <label class="filter-item" style="padding: 15px; border: 1px solid var(--border-color); width: 100%;">
                        <input type="radio" name="paymentMethod" value="COD" checked onchange="toggleBankDetails()">
                        <div>
                            <strong>Thanh toán khi nhận hàng (COD)</strong>
                            <p style="font-size: 12px; color: var(--text-secondary); margin-top: 5px;">Bạn sẽ thanh toán bằng tiền mặt cho nhân viên giao hàng khi nhận được sản phẩm.</p>
                        </div>
                    </label>

                    <label class="filter-item" style="padding: 15px; border: 1px solid var(--border-color); width: 100%; margin-top: 10px;">
                        <input type="radio" name="paymentMethod" value="BANK_TRANSFER" onchange="toggleBankDetails()">
                        <div>
                            <strong>Chuyển khoản ngân hàng (Hiển thị QR)</strong>
                            <p style="font-size: 12px; color: var(--text-secondary); margin-top: 5px;">Thanh toán qua tài khoản ngân hàng bằng cách quét mã QR tự động.</p>
                        </div>
                    </label>
                </div>

                <!-- Bank transfer details (Hidden by default) -->
                <div id="bankDetailsArea" style="display: none; border: 1px solid var(--border-color-dark); padding: 25px; margin-bottom: 30px; background-color: var(--bg-secondary);">
                    <h4 style="font-size: 14px; font-weight: 700; text-transform: uppercase; margin-bottom: 15px;">Thông Tin Tài Khoản Ngân Hàng</h4>
                    <div style="display: flex; gap: 30px; align-items: center; flex-wrap: wrap;">
                        <div style="flex-grow: 1; font-size: 13px;">
                            <p style="margin-bottom: 8px;">Ngân hàng: <strong>MB BANK (Ngân hàng Quân đội)</strong></p>
                            <p style="margin-bottom: 8px;">Số tài khoản: <strong>123456789999</strong></p>
                            <p style="margin-bottom: 8px;">Chủ tài khoản: <strong>CÔNG TY TRENDIFY VIỆT NAM</strong></p>
                            <p style="margin-bottom: 8px;">Số tiền: <strong><fmt:formatNumber value="${cartTotal}" maxFractionDigits="0"/> đ</strong></p>
                            <p style="margin-bottom: 8px;">Nội dung chuyển khoản: <strong>TDF <c:out value="${orderCode}"/></strong></p>
                            <p style="font-size: 11px; color: var(--text-secondary); margin-top: 15px;">* Đơn hàng sẽ được xác nhận sau khi hệ thống nhận được thanh toán của bạn.</p>
                        </div>
                        <!-- VietQR Automatic QR Generation -->
                        <div style="text-align: center;">
                            <img src="https://img.vietqr.io/image/MB-123456789999-compact.png?amount=${cartTotal}&addInfo=TDF%20${orderCode}&accountName=CONG%20TY%20TRENDIFY%20VIET%20NAM" 
                                 alt="VietQR MBBank" style="width: 150px; height: 150px; border: 1px solid var(--border-color); transition: var(--transition);">
                            <div style="font-size: 10px; color: var(--text-muted); margin-top: 5px;">Quét để thanh toán tự động</div>
                        </div>
                    </div>
                </div>

                <input type="hidden" name="orderCode" value="${orderCode}">
                
                <button type="submit" class="btn btn-dark" style="width: 100%; padding: 15px;">Đặt Hàng Ngay</button>
            </form>
        </div>

        <!-- Order Summary Sidebar -->
        <div class="cart-summary" style="width: 380px;">
            <h3 style="font-size: 16px; font-weight: 700; text-transform: uppercase; margin-bottom: 25px; letter-spacing: 1px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                Đơn Hàng Của Bạn
            </h3>

            <!-- Products List -->
            <div style="max-height: 250px; overflow-y: auto; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 15px;">
                <c:forEach var="item" items="${cartItems}">
                    <div style="display: flex; gap: 15px; margin-bottom: 15px; font-size: 13px; align-items: center;">
                        <img src="${item.productImageUrl}" alt="${item.productName}" style="width: 50px; height: 60px; object-fit: cover; border: 1px solid var(--border-color);">
                        <div style="flex-grow: 1;">
                            <h4 style="font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 180px;"><c:out value="${item.productName}"/></h4>
                            <p style="color: var(--text-secondary); font-size: 11px;">PL: <c:out value="${item.color}"/> / KC: <c:out value="${item.size}"/></p>
                            <p style="color: var(--text-secondary); font-size: 11px;">SL: ${item.quantity}</p>
                        </div>
                        <div style="font-weight: 600;">
                            <fmt:formatNumber value="${item.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Price Breakdown -->
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
                <span>Phí giao hàng</span>
                <span>Miễn phí</span>
            </div>

            <div class="summary-row total">
                <span>Tổng thanh toán</span>
                <span>
                    <fmt:formatNumber value="${cartTotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </span>
            </div>
            
            <a href="${pageContext.request.contextPath}/cart" style="font-size: 12px; text-decoration: underline; color: var(--text-secondary); display: block; text-align: center;">Quay về chỉnh sửa giỏ hàng</a>
        </div>
    </div>
</main>

<script>
    function toggleBankDetails() {
        const rads = document.getElementsByName("paymentMethod");
        const bankArea = document.getElementById("bankDetailsArea");
        
        let selectedValue = "";
        for (let i = 0; i < rads.length; i++) {
            if (rads[i].checked) {
                selectedValue = rads[i].value;
                break;
            }
        }
        
        if (selectedValue === "BANK_TRANSFER") {
            bankArea.style.display = "block";
        } else {
            bankArea.style.display = "none";
        }
    }
</script>

<jsp:include page="layout/footer.jsp" />

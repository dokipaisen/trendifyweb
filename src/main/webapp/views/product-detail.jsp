<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="layout/header.jsp">
    <jsp:param name="pageTitle" value="Trendify - ${product.name}" />
</jsp:include>

<main>
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

    <div class="product-detail-layout">
        <!-- Gallery -->
        <div class="product-gallery">
            <div class="main-image">
                <img id="mainProductImg" src="${product.imageUrl}" alt="${product.name}">
            </div>
            <div class="thumbnail-list">
                <div class="thumbnail active" onclick="changeImage('${product.imageUrl}', this)">
                    <img src="${product.imageUrl}" alt="${product.name}">
                </div>
                <c:forEach var="img" items="${images}">
                    <div class="thumbnail" onclick="changeImage('${img.imageUrl}', this)">
                        <img src="${img.imageUrl}" alt="Secondary Image">
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- Details -->
        <div class="product-details">
            <div class="product-brand"><c:out value="${product.brand}"/></div>
            <h1 class="product-title"><c:out value="${product.name}"/></h1>
            
            <div class="product-meta-row">
                <div class="stars">
                    <c:forEach var="i" begin="1" end="5">
                        <c:choose>
                            <c:when test="${i <= product.rating}">
                                <span class="star-filled">★</span>
                            </c:when>
                            <c:otherwise>
                                <span class="star-empty">☆</span>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <span style="margin-left: 5px; color: var(--text-secondary);">(${product.rating} / 5.0)</span>
                </div>
                <span>|</span>
                <span id="stockDisplay">Đang kiểm tra kho hàng...</span>
            </div>

            <div class="product-price-large">
                <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
            </div>

            <p class="product-description-text">
                <c:out value="${product.description}" escapeXml="false"/>
            </p>

            <form action="${pageContext.request.contextPath}/cart" method="POST" id="addToCartForm" onsubmit="return validateSelection()">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="productId" value="${product.id}">
                <input type="hidden" name="variantId" id="selectedVariantId" value="">

                <!-- Size Selection -->
                <div class="variant-selection">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                        <div class="variant-title" style="margin-bottom: 0;">Kích Cỡ</div>
                        <a href="javascript:void(0)" onclick="openSizePredictorModal()" style="font-size: 12px; text-decoration: underline; color: var(--primary-color); font-weight: 600;">Gợi ý chọn size</a>
                    </div>
                    <div class="variant-options" id="sizeOptions">
                        <!-- Dynamic sizing -->
                    </div>
                </div>

                <!-- Color Selection -->
                <div class="variant-selection">
                    <div class="variant-title">Màu Sắc</div>
                    <div class="variant-options" id="colorOptions">
                        <!-- Dynamic colors -->
                    </div>
                </div>

                <!-- Add to Cart actions -->
                <div class="add-to-cart-section">
                    <div class="quantity-selector">
                        <button type="button" class="quantity-btn" onclick="adjustQty(-1)">-</button>
                        <input type="number" name="quantity" id="quantityInput" class="quantity-input" value="1" min="1" max="99">
                        <button type="button" class="quantity-btn" onclick="adjustQty(1)">+</button>
                    </div>
                    <button type="submit" class="btn btn-dark" id="addToCartBtn" disabled style="flex-grow: 1;">Vui lòng chọn phân loại</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Reviews Section -->
    <div class="reviews-section">
        <h3 class="section-title">Đánh giá từ khách hàng (${reviews.size()})</h3>

        <c:choose>
            <c:when test="${not empty reviews}">
                <div style="display: flex; flex-direction: column; gap: 20px; margin-bottom: 40px;">
                    <c:forEach var="r" items="${reviews}">
                        <div class="review-item">
                            <div class="review-header">
                                <span class="review-user"><c:out value="${r.userFullName}"/></span>
                                <span class="review-date"><fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                            </div>
                            <div class="stars" style="margin-bottom: 8px;">
                                <c:forEach var="i" begin="1" end="5">
                                    <c:choose>
                                        <c:when test="${i <= r.rating}">
                                            <span class="star-filled">★</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="star-empty">☆</span>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </div>
                            <p class="review-comment"><c:out value="${r.comment}"/></p>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div style="padding: 40px; text-align: center; border: 1px dashed var(--border-color); color: var(--text-secondary); margin-bottom: 40px;">
                    Chưa có đánh giá nào cho sản phẩm này.
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Write Review Form -->
        <c:choose>
            <c:when test="${not empty sessionScope.currentUser}">
                <div style="border: 1px solid var(--border-color-dark); padding: 30px; max-width: 600px;">
                    <h4 style="font-size: 16px; font-weight: 700; text-transform: uppercase; margin-bottom: 20px;">Viết Đánh Giá</h4>
                    <form action="${pageContext.request.contextPath}/product/detail" method="POST">
                        <input type="hidden" name="productId" value="${product.id}">
                        
                        <div class="form-group">
                            <label>Điểm Đánh Giá</label>
                            <select name="rating" required style="width: 100%;">
                                <option value="5">5 Sao - Rất tốt</option>
                                <option value="4">4 Sao - Tốt</option>
                                <option value="3">3 Sao - Bình thường</option>
                                <option value="2">2 Sao - Kém</option>
                                <option value="1">1 Sao - Rất tệ</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Nhận Xét</label>
                            <textarea name="comment" rows="4" required style="width: 100%; resize: vertical;" placeholder="Chia sẻ trải nghiệm của bạn về sản phẩm..."></textarea>
                        </div>

                        <button type="submit" class="btn btn-dark" style="width: 100%;">Gửi Nhận Xét</button>
                    </form>
                </div>
            </c:when>
            <c:otherwise>
                <div style="border: 1px solid var(--border-color); padding: 20px; text-align: center; font-size: 14px; color: var(--text-secondary);">
                    Vui lòng <a href="${pageContext.request.contextPath}/login" style="text-decoration: underline; font-weight: 600; color: var(--primary-color);">đăng nhập</a> để gửi đánh giá của bạn.
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Size Predictor Modal -->
    <div id="sizePredictorModal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.5); backdrop-filter: blur(4px); align-items: center; justify-content: center; opacity: 0; transition: opacity 0.3s ease;">
        <div style="background-color: var(--bg-primary); border: 1px solid var(--border-color); padding: 30px; border-radius: 12px; width: 90%; max-width: 400px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); position: relative; animation: slideDown 0.3s ease;">
            <span onclick="closeSizePredictorModal()" style="position: absolute; right: 20px; top: 15px; font-size: 24px; font-weight: bold; cursor: pointer; color: var(--text-secondary);">&times;</span>
            <h3 style="font-size: 18px; font-weight: 700; text-transform: uppercase; margin-bottom: 20px; color: var(--text-primary); border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">Gợi ý chọn size phù hợp</h3>
            
            <div style="display: flex; flex-direction: column; gap: 15px; margin-bottom: 25px;">
                <div style="display: flex; flex-direction: column; gap: 6px;">
                    <label style="font-size: 12px; font-weight: 600; text-transform: uppercase; color: var(--text-secondary); text-align: left;">Chiều cao (cm):</label>
                    <input type="number" id="modalHeightInput" placeholder="Ví dụ: 170" min="100" max="250" style="width: 100%; padding: 10px 14px; border-radius: 6px; box-sizing: border-box;">
                </div>
                <div style="display: flex; flex-direction: column; gap: 6px;">
                    <label style="font-size: 12px; font-weight: 600; text-transform: uppercase; color: var(--text-secondary); text-align: left;">Cân nặng (kg):</label>
                    <input type="number" id="modalWeightInput" placeholder="Ví dụ: 65" min="30" max="150" style="width: 100%; padding: 10px 14px; border-radius: 6px; box-sizing: border-box;">
                </div>
            </div>

            <!-- Result Section -->
            <div id="modalResultSection" style="display: none; background-color: var(--primary-light); border: 1px solid var(--border-color-dark); padding: 15px; border-radius: 8px; margin-bottom: 25px; text-align: left;">
                <p style="font-size: 14px; margin-bottom: 5px; color: var(--text-primary);">Size đề xuất của bạn: <strong id="modalRecommendedSize" style="font-size: 18px; color: var(--primary-color);">M</strong></p>
                <p id="modalFitAdvice" style="font-size: 12px; color: var(--text-secondary); line-height: 1.4;"></p>
            </div>

            <div style="display: flex; gap: 12px;">
                <button type="button" onclick="calculateModalSize()" class="btn btn-dark" style="flex: 1; border-radius: 6px; padding: 12px;">Tính Size</button>
                <button type="button" id="modalApplyBtn" onclick="applyRecommendedSize()" class="btn btn-light" disabled style="flex: 1; border-radius: 6px; padding: 12px; display: none;">Áp dụng size này</button>
            </div>
        </div>
    </div>

    <style>
        @keyframes slideDown {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
    </style>
</main>

<script>
    // Embedded JSON Array of Variants
    const variants = [
        <c:forEach var="v" items="${variants}" varStatus="status">
            {
                id: ${v.id},
                size: "${v.size}",
                color: "${v.color}",
                stock: ${v.stock}
            }${not status.last ? ',' : ''}
        </c:forEach>
    ];

    let selectedSize = "";
    let selectedColor = "";

    function changeImage(url, element) {
        document.getElementById("mainProductImg").src = url;
        document.querySelectorAll(".thumbnail").forEach(t => t.classList.remove("active"));
        element.classList.add("active");
    }

    function adjustQty(amount) {
        const input = document.getElementById("quantityInput");
        let val = parseInt(input.value) + amount;
        if (val < 1) val = 1;
        
        // Find max stock if variant selected
        const currentVariant = findMatchingVariant();
        if (currentVariant && val > currentVariant.stock) {
            val = currentVariant.stock;
        }
        input.value = val;
    }

    // Populate variant selections
    function initVariants() {
        const sizeOptionsDiv = document.getElementById("sizeOptions");
        const colorOptionsDiv = document.getElementById("colorOptions");

        // Extract unique sizes and colors
        const sizes = [...new Set(variants.map(v => v.size))];
        const colors = [...new Set(variants.map(v => v.color))];

        sizes.forEach(size => {
            const btn = document.createElement("div");
            btn.className = "variant-option";
            btn.innerText = size;
            btn.onclick = () => selectSize(size, btn);
            sizeOptionsDiv.appendChild(btn);
        });

        colors.forEach(color => {
            const btn = document.createElement("div");
            btn.className = "variant-option";
            btn.innerText = color;
            btn.onclick = () => selectColor(color, btn);
            colorOptionsDiv.appendChild(btn);
        });

        updateStockDisplay();
    }

    function selectSize(size, element) {
        selectedSize = size;
        document.querySelectorAll("#sizeOptions .variant-option").forEach(el => el.classList.remove("active"));
        element.classList.add("active");
        onSelectionChange();
    }

    function selectColor(color, element) {
        selectedColor = color;
        document.querySelectorAll("#colorOptions .variant-option").forEach(el => el.classList.remove("active"));
        element.classList.add("active");
        onSelectionChange();
    }

    function findMatchingVariant() {
        if (!selectedSize || !selectedColor) return null;
        return variants.find(v => v.size === selectedSize && v.color === selectedColor);
    }

    function onSelectionChange() {
        const variant = findMatchingVariant();
        const addToCartBtn = document.getElementById("addToCartBtn");
        const variantIdInput = document.getElementById("selectedVariantId");
        
        if (variant) {
            variantIdInput.value = variant.id;
            updateStockDisplay(variant.stock);
            
            if (variant.stock > 0) {
                addToCartBtn.disabled = false;
                addToCartBtn.innerText = "Thêm Vào Giỏ Hàng";
                
                // Adjust quantity input if exceeds stock
                const qtyInput = document.getElementById("quantityInput");
                if (parseInt(qtyInput.value) > variant.stock) {
                    qtyInput.value = variant.stock;
                }
                qtyInput.max = variant.stock;
            } else {
                addToCartBtn.disabled = true;
                addToCartBtn.innerText = "Hết Hàng";
            }
        } else {
            variantIdInput.value = "";
            updateStockDisplay();
            addToCartBtn.disabled = true;
            addToCartBtn.innerText = "Vui lòng chọn phân loại";
        }
    }

    function updateStockDisplay(stock) {
        const display = document.getElementById("stockDisplay");
        if (stock === undefined) {
            if (selectedSize && selectedColor) {
                display.innerHTML = "<span style='color: #666;'>Không có sẵn</span>";
            } else {
                display.innerText = "Vui lòng chọn kích cỡ và màu sắc";
            }
        } else {
            if (stock > 0) {
                display.innerHTML = "Còn lại: <strong>" + stock + "</strong> sản phẩm";
            } else {
                display.innerHTML = "<span style='color: #666;'>Hết hàng</span>";
            }
        }
    }

    function validateSelection() {
        if (!selectedSize || !selectedColor) {
            alert("Vui lòng chọn Kích Cỡ và Màu Sắc!");
            return false;
        }
        return true;
    }

    // Modal size prediction Javascript
    let recommendedModalSize = "";

    function openSizePredictorModal() {
        const modal = document.getElementById("sizePredictorModal");
        modal.style.display = "flex";
        setTimeout(() => {
            modal.style.opacity = "1";
        }, 10);
    }

    function closeSizePredictorModal() {
        const modal = document.getElementById("sizePredictorModal");
        modal.style.opacity = "0";
        setTimeout(() => {
            modal.style.display = "none";
            // Reset modal state
            document.getElementById("modalHeightInput").value = "";
            document.getElementById("modalWeightInput").value = "";
            document.getElementById("modalResultSection").style.display = "none";
            document.getElementById("modalApplyBtn").style.display = "none";
            document.getElementById("modalApplyBtn").disabled = true;
            recommendedModalSize = "";
        }, 300);
    }

    function getRecommendedSize(height, weight) {
        if (isNaN(height) || isNaN(weight)) return null;
        
        if (weight < 40) return { size: "XS", fitAdvice: "Dành cho người có cân nặng dưới 45kg." };
        if (weight > 95) return { size: "XXXL", fitAdvice: "Vượt quá bảng kích cỡ tiêu chuẩn, vui lòng liên hệ hotline 1900 6066 để được đặt may riêng." };
        
        let size = "";
        if (weight >= 40 && weight < 50) {
            size = (height < 155) ? "S" : "XS";
        } else if (weight >= 50 && weight < 58) {
            size = (height < 162) ? "M" : "S";
        } else if (weight >= 58 && weight < 66) {
            size = (height < 169) ? "L" : "M";
        } else if (weight >= 66 && weight < 75) {
            size = (height < 176) ? "XL" : "L";
        } else if (weight >= 75 && weight < 85) {
            size = (height < 182) ? "XXL" : "XL";
        } else {
            size = "XXL";
        }
        
        let fitAdvice = "";
        if (size === "S") fitAdvice = "Phù hợp cho chiều cao 1m50 - 1m60 và cân nặng 45kg - 52kg.";
        else if (size === "M") fitAdvice = "Phù hợp cho chiều cao 1m60 - 1m67 và cân nặng 53kg - 61kg.";
        else if (size === "L") fitAdvice = "Phù hợp cho chiều cao 1m67 - 1m74 và cân nặng 62kg - 70kg.";
        else if (size === "XL") fitAdvice = "Phù hợp cho chiều cao 1m74 - 1m81 và cân nặng 71kg - 79kg.";
        else if (size === "XXL") fitAdvice = "Phù hợp cho chiều cao 1m81 - 1m88 và cân nặng 80kg - 90kg.";
        
        return { size, fitAdvice };
    }

    function calculateModalSize() {
        const h = parseInt(document.getElementById("modalHeightInput").value);
        const w = parseInt(document.getElementById("modalWeightInput").value);

        if (!h || !w || h <= 0 || w <= 0) {
            alert("Vui lòng nhập đầy đủ chiều cao và cân nặng!");
            return;
        }

        const res = getRecommendedSize(h, w);
        if (res) {
            recommendedModalSize = res.size;
            document.getElementById("modalRecommendedSize").innerText = res.size;
            document.getElementById("modalFitAdvice").innerText = res.fitAdvice + " Nếu muốn mặc rộng rãi thoải mái, bạn có thể chọn lớn hơn 1 size.";
            document.getElementById("modalResultSection").style.display = "block";
            
            const applyBtn = document.getElementById("modalApplyBtn");
            applyBtn.style.display = "inline-flex";
            applyBtn.disabled = false;
        } else {
            alert("Không thể tính size hợp lệ cho số đo này.");
        }
    }

    function applyRecommendedSize() {
        if (!recommendedModalSize) return;

        const sizeOptions = document.querySelectorAll("#sizeOptions .variant-option");
        let found = false;

        sizeOptions.forEach(opt => {
            if (opt.innerText.trim().toUpperCase() === recommendedModalSize.toUpperCase()) {
                opt.click();
                found = true;
            }
        });

        if (found) {
            closeSizePredictorModal();
        } else {
            alert("Sản phẩm này hiện tại không có sẵn size " + recommendedModalSize + ". Vui lòng chọn size khác hoặc liên hệ hotline!");
        }
    }

    document.addEventListener("DOMContentLoaded", initVariants);
</script>

<jsp:include page="layout/footer.jsp" />

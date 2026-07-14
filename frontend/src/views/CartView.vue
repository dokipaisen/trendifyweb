<template>
  <div class="cart-page fade-in">
    <div class="container">
      <h1 class="section-title">Giỏ hàng của bạn</h1>

      <div v-if="cartStore.items.length === 0" class="empty-cart card">
        <span class="empty-cart-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
        </span>
        <h2>Giỏ hàng đang trống</h2>
        <p>Có vẻ như bạn chưa chọn được món đồ ưng ý. Hãy ghé qua cửa hàng của chúng tôi để mua sắm ngay nhé!</p>
        <router-link to="/shop" class="btn btn-primary">Ghé cửa hàng</router-link>
      </div>

      <div v-else class="cart-layout">
        <!-- Cart Items List -->
        <div class="cart-items-column">
          <div class="cart-header-row">
            <span>Sản phẩm</span>
            <span>Giá</span>
            <span>Số lượng</span>
            <span>Tổng tiền</span>
            <span>Tác vụ</span>
          </div>

          <div class="cart-item-card card" v-for="item in cartStore.items" :key="item.variantId">
            <div class="cart-item-product">
              <div class="item-img-wrapper">
                <img :src="item.productImageUrl" :alt="item.productName">
              </div>
              <div class="item-details">
                <span class="item-brand">{{ item.productBrand }}</span>
                <router-link :to="'/products/' + item.productId">
                  <h4 class="item-name">{{ item.productName }}</h4>
                </router-link>
                <div class="item-specs">
                  <span>Size: <strong>{{ item.size }}</strong></span>
                  <span class="dot-separator">•</span>
                  <span>Màu: <strong>{{ item.color }}</strong></span>
                </div>
              </div>
            </div>

            <div class="cart-item-price">
              {{ formatCurrency(item.price) }}
            </div>

            <div class="cart-item-quantity">
              <div class="quantity-selector">
                <button @click="updateQty(item.variantId, item.quantity - 1)" class="qty-btn" :disabled="item.quantity <= 1">-</button>
                <input type="number" :value="item.quantity" @change="updateQty(item.variantId, $event.target.value)" readonly class="qty-input">
                <button @click="updateQty(item.variantId, item.quantity + 1)" class="qty-btn">+</button>
              </div>
            </div>

            <div class="cart-item-total">
              {{ formatCurrency(item.price * item.quantity) }}
            </div>

            <div class="cart-item-actions">
              <button @click="removeFromCart(item.variantId)" class="remove-btn">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"></path><path d="M10 11v6"></path><path d="M14 11v6"></path><path d="M9 6V4h6v2"></path></svg>
                Xoá
              </button>
            </div>
          </div>

          <div class="cart-actions-row">
            <router-link to="/shop" class="btn btn-outline">← Tiếp tục mua sắm</router-link>
            <button @click="clearCart" class="btn btn-outline btn-danger">Xoá toàn bộ giỏ hàng</button>
          </div>
        </div>

        <!-- Order Summary Card -->
        <div class="cart-summary-column">
          <div class="card summary-card">
            <h3>Tóm tắt đơn hàng</h3>
            
            <div class="summary-row">
              <span>Tạm tính</span>
              <span>{{ formatCurrency(cartStore.subtotal) }}</span>
            </div>

            <!-- Voucher Section -->
            <div class="voucher-section">
              <div v-if="cartStore.appliedVoucher" class="applied-voucher">
                <div class="voucher-info">
                  <span class="voucher-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line></svg>
                  </span>
                  <div>
                    <span class="voucher-code">{{ cartStore.appliedVoucher.code }}</span>
                    <p class="voucher-desc">
                      Đã giảm {{ formatCurrency(cartStore.discountAmount) }}
                    </p>
                  </div>
                </div>
                <button @click="removeVoucher" class="remove-voucher-btn">&times;</button>
              </div>

              <div v-else class="voucher-input-row">
                <input 
                  type="text" 
                  v-model="voucherCode" 
                  placeholder="Nhập mã giảm giá..."
                  class="form-control voucher-input"
                >
                <button @click="applyVoucher" class="btn btn-dark" :disabled="!voucherCode">
                  Áp dụng
                </button>
              </div>
              <p v-if="voucherError" class="voucher-error-msg">{{ voucherError }}</p>
            </div>

            <div class="summary-row" v-if="cartStore.discountAmount > 0">
              <span>Khuyến mãi</span>
              <span class="discount-val">-{{ formatCurrency(cartStore.discountAmount) }}</span>
            </div>

            <div class="summary-row">
              <span>Phí vận chuyển</span>
              <span>Miễn phí</span>
            </div>

            <div class="summary-divider"></div>

            <div class="summary-row total-row">
              <span>Tổng cộng</span>
              <span>{{ formatCurrency(cartStore.totalAmount) }}</span>
            </div>

            <router-link to="/checkout" class="btn btn-primary btn-lg checkout-btn">
              Tiến hành thanh toán
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import { useCartStore } from '../stores/cart';

export default {
  name: 'CartView',
  setup() {
    const cartStore = useCartStore();
    const voucherCode = ref('');
    const voucherError = ref('');

    const updateQty = async (variantId, qty) => {
      if (qty <= 0) return;
      await cartStore.updateQuantity(variantId, qty);
    };

    const removeFromCart = async (variantId) => {
      if (confirm('Bạn có chắc chắn muốn xoá sản phẩm này khỏi giỏ hàng?')) {
        await cartStore.removeFromCart(variantId);
      }
    };

    const clearCart = async () => {
      if (confirm('Bạn có chắc chắn muốn làm trống giỏ hàng của mình?')) {
        await cartStore.clearCart();
      }
    };

    const applyVoucher = async () => {
      voucherError.value = '';
      try {
        await cartStore.applyVoucher(voucherCode.value);
        voucherCode.value = '';
      } catch (err) {
        voucherError.value = err.response?.data?.message || 'Mã giảm giá không hợp lệ.';
      }
    };

    const removeVoucher = () => {
      cartStore.removeVoucher();
      voucherError.value = '';
    };

    const formatCurrency = (val) => {
      if (!val) return '0đ';
      return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
    };

    return {
      cartStore,
      voucherCode,
      voucherError,
      updateQty,
      removeFromCart,
      clearCart,
      applyVoucher,
      removeVoucher,
      formatCurrency
    };
  }
};
</script>

<style scoped>
.cart-page {
  padding: 60px 0;
}

.empty-cart {
  text-align: center;
  padding: 60px;
  max-width: 600px;
  margin: 0 auto;
}

.empty-cart-icon {
  font-size: 64px;
  margin-bottom: 20px;
  display: block;
}

.empty-cart h2 {
  font-size: 24px;
  margin-bottom: 12px;
}

.empty-cart p {
  color: var(--gray);
  margin-bottom: 24px;
}

.cart-layout {
  display: grid;
  grid-template-columns: 1fr 380px;
  gap: 40px;
  align-items: start;
}

/* Cart Items column styling */
.cart-items-column {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.cart-header-row {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr 100px;
  padding: 0 24px;
  font-size: 14px;
  font-weight: 700;
  color: var(--gray-dark);
  text-transform: uppercase;
}

.cart-item-card {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr 100px;
  align-items: center;
  padding: 16px 24px;
  background: var(--white);
}

.cart-item-product {
  display: flex;
  gap: 16px;
  align-items: center;
}

.item-img-wrapper {
  width: 80px;
  height: 80px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  border: 1px solid var(--border);
  background: var(--gray-light);
}

.item-img-wrapper img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.item-details {
  display: flex;
  flex-direction: column;
}

.item-brand {
  font-size: 11px;
  font-weight: 700;
  color: var(--primary);
  text-transform: uppercase;
}

.item-name {
  font-size: 15px;
  font-weight: 600;
  margin: 2px 0 6px 0;
  color: var(--dark-light);
}

.item-specs {
  font-size: 12px;
  color: var(--gray);
  display: flex;
  align-items: center;
  gap: 6px;
}

.dot-separator {
  color: var(--border);
}

.cart-item-price, .cart-item-total {
  font-size: 16px;
  font-weight: 600;
}

.cart-item-total {
  color: var(--primary);
}

.quantity-selector {
  display: inline-flex;
  align-items: center;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  overflow: hidden;
}

.qty-btn {
  background: transparent;
  border: none;
  font-size: 16px;
  padding: 4px 10px;
  cursor: pointer;
}

.qty-input {
  width: 30px;
  text-align: center;
  border: none;
  font-size: 14px;
  font-weight: 700;
  padding: 0;
}

.remove-btn {
  background: transparent;
  border: none;
  color: #e74c3c;
  font-weight: 600;
  font-size: 13px;
  cursor: pointer;
}

.cart-actions-row {
  display: flex;
  justify-content: space-between;
  margin-top: 20px;
}

/* Order Summary Column styling */
.summary-card h3 {
  font-size: 20px;
  margin-bottom: 24px;
  border-bottom: 2px solid var(--gray-light);
  padding-bottom: 12px;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  font-size: 15px;
  font-weight: 500;
  margin-bottom: 16px;
  color: var(--gray-dark);
}

.discount-val {
  color: #2ecc71;
  font-weight: 700;
}

.summary-divider {
  height: 1px;
  background: var(--border);
  margin: 20px 0;
}

.total-row {
  font-size: 20px;
  font-weight: 800;
  color: var(--dark);
}

.checkout-btn {
  width: 100%;
  margin-top: 24px;
}

/* Voucher Section styling */
.voucher-section {
  background: #fdfbf7;
  border: 1px dashed var(--primary);
  border-radius: var(--radius);
  padding: 16px;
  margin-bottom: 20px;
}

.voucher-input-row {
  display: flex;
  gap: 10px;
}

.voucher-input {
  flex: 1;
  padding: 8px 12px;
  font-size: 13px;
}

.applied-voucher {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.voucher-info {
  display: flex;
  gap: 10px;
  align-items: center;
}

.voucher-icon {
  font-size: 20px;
}

.voucher-code {
  font-weight: 700;
  color: var(--primary);
}

.voucher-desc {
  font-size: 12px;
  color: var(--gray-dark);
}

.remove-voucher-btn {
  background: transparent;
  border: none;
  font-size: 20px;
  color: var(--gray);
  cursor: pointer;
}

.voucher-error-msg {
  color: #e74c3c;
  font-size: 12px;
  margin-top: 8px;
  font-weight: 600;
}

@media (max-width: 992px) {
  .cart-layout {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .cart-header-row {
    display: none;
  }
  .cart-item-card {
    grid-template-columns: 1fr;
    gap: 16px;
    text-align: center;
  }
  .cart-item-product {
    flex-direction: column;
  }
}
</style>

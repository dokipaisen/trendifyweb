<template>
  <div class="checkout-page fade-in">
    <div class="container">
      <h1 class="section-title">Thanh toán đơn hàng</h1>

      <div v-if="loading" class="loader">Đang xử lý đơn hàng...</div>
      
      <div v-else class="checkout-layout">
        <!-- Billing Information Form -->
        <div class="billing-column card">
          <h3>Thông tin giao hàng</h3>
          <form @submit.prevent="handleCheckout" class="checkout-form">
            <div class="form-group">
              <label for="fullName">Họ và tên người nhận *</label>
              <input 
                type="text" 
                id="fullName" 
                v-model="orderForm.fullName" 
                required 
                placeholder="Nhập đầy đủ họ tên..."
                class="form-control"
              >
            </div>

            <div class="form-group">
              <label for="phone">Số điện thoại *</label>
              <input 
                type="tel" 
                id="phone" 
                v-model="orderForm.phone" 
                required 
                placeholder="Nhập số điện thoại nhận hàng..."
                class="form-control"
              >
            </div>

            <div class="form-group">
              <label for="address">Địa chỉ giao hàng *</label>
              <input 
                type="text" 
                id="address" 
                v-model="orderForm.address" 
                required 
                placeholder="Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/TP..."
                class="form-control"
              >
            </div>

            <div class="form-group">
              <label for="notes">Ghi chú đơn hàng (nếu có)</label>
              <textarea 
                id="notes" 
                v-model="orderForm.notes" 
                rows="3" 
                placeholder="Ví dụ: giao giờ hành chính, gọi điện trước khi giao..."
                class="form-control"
              ></textarea>
            </div>

            <div class="form-group">
              <label>Phương thức thanh toán *</label>
              <div class="payment-options">
                <label class="payment-option-card" :class="{ active: orderForm.paymentMethod === 'COD' }">
                  <input type="radio" v-model="orderForm.paymentMethod" value="COD">
                  <span class="payment-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
                  </span>
                  <div>
                    <strong>COD (Thanh toán khi nhận hàng)</strong>
                    <p>Nhận hàng và thanh toán tiền mặt trực tiếp cho shipper.</p>
                  </div>
                </label>

                <label class="payment-option-card" :class="{ active: orderForm.paymentMethod === 'BANK_TRANSFER' }">
                  <input type="radio" v-model="orderForm.paymentMethod" value="BANK_TRANSFER">
                  <span class="payment-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="3" y1="9" x2="21" y2="9"></line><line x1="9" y1="21" x2="9" y2="9"></line></svg>
                  </span>
                  <div>
                    <strong>Chuyển khoản ngân hàng (VietQR)</strong>
                    <p>Quét mã QR bằng ứng dụng ngân hàng để thanh toán tự động.</p>
                  </div>
                </label>
              </div>
            </div>

            <!-- Error banner -->
            <div v-if="checkoutError" class="alert alert-error">
              {{ checkoutError }}
            </div>

            <button type="submit" class="btn btn-primary btn-lg submit-order-btn" :disabled="submitting">
              {{ submitting ? 'Đang đặt hàng...' : 'Xác nhận đặt hàng' }}
            </button>
          </form>
        </div>

        <!-- Order Summary Column -->
        <div class="order-summary-column">
          <div class="card summary-card">
            <h3>Chi tiết giỏ hàng</h3>
            
            <div class="order-items-list">
              <div class="order-item-row" v-for="item in cartStore.items" :key="item.variantId">
                <div class="item-info">
                  <span class="item-name">{{ item.productName }}</span>
                  <span class="item-specs">{{ item.size }} / {{ item.color }} (x{{ item.quantity }})</span>
                </div>
                <span class="item-price">{{ formatCurrency(item.price * item.quantity) }}</span>
              </div>
            </div>

            <div class="summary-divider"></div>

            <div class="summary-row">
              <span>Tạm tính</span>
              <span>{{ formatCurrency(cartStore.subtotal) }}</span>
            </div>

            <div class="summary-row" v-if="cartStore.discountAmount > 0">
              <span>Mã giảm giá áp dụng</span>
              <span class="discount-val">-{{ formatCurrency(cartStore.discountAmount) }}</span>
            </div>

            <div class="summary-row">
              <span>Phí vận chuyển</span>
              <span>Miễn phí</span>
            </div>

            <div class="summary-divider"></div>

            <div class="summary-row total-row">
              <span>Tổng thanh toán</span>
              <span>{{ formatCurrency(cartStore.totalAmount) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal QR Thanh toán Chuyển khoản VietQR -->
    <div v-if="showPaymentModal" class="modal-overlay">
      <div class="modal-content card qr-payment-modal">
        <div class="modal-header">
          <h2>Thanh toán chuyển khoản VietQR</h2>
          <button @click="closePaymentModal" class="close-modal">&times;</button>
        </div>
        <div class="qr-body text-center" v-if="currentOrder">
          <div class="apipay-button-wrapper" v-if="currentOrder.payUrl">
            <a :href="currentOrder.payUrl" target="_blank" class="btn btn-primary apipay-btn">
              Đi đến cổng thanh toán PayOS
            </a>
            <p class="apipay-hint">Hoặc quét nhanh bằng VietQR trực tiếp tại đây:</p>
          </div>
          <p class="qr-instruction-title" v-else>Mở ứng dụng ngân hàng quét mã QR để thanh toán tự động</p>
          
          <div class="qr-code-wrapper">
            <img :src="vietQrUrl" alt="Mã QR thanh toán VietQR">
          </div>

          <div class="qr-details">
            <p><span>Chủ tài khoản:</span> <strong>TRENDIFY STORE</strong></p>
            <p><span>Số tài khoản:</span> <strong>0987654321</strong></p>
            <p><span>Ngân hàng:</span> <strong>MB Bank (Ngân hàng Quân đội)</strong></p>
            <p><span>Số tiền:</span> <strong class="price-txt">{{ formatCurrency(currentOrder.totalAmount) }}</strong></p>
            <p><span>Nội dung chuyển khoản:</span> <strong class="code-txt">{{ currentOrder.orderCode }}</strong></p>
          </div>

          <div class="polling-status">
            <span class="pulse-indicator"></span>
            <span>Hệ thống đang tự động kiểm tra giao dịch chuyển tiền...</span>
          </div>

          <div class="simulation-actions">
            <button type="button" @click="triggerSimulatePayment" class="btn btn-outline btn-sm sim-btn" :disabled="simulating">
              {{ simulating ? 'Đang gửi thông tin...' : 'Giả lập chuyển khoản thành công (Simulate Webhook)' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { useCartStore } from '../stores/cart';
import axios from 'axios';

export default {
  name: 'CheckoutView',
  setup() {
    const router = useRouter();
    const authStore = useAuthStore();
    const cartStore = useCartStore();

    const loading = ref(true);
    const submitting = ref(false);
    const checkoutError = ref('');

    // VietQR Modal States
    const showPaymentModal = ref(false);
    const currentOrder = ref(null);
    const vietQrUrl = ref('');
    const pollingInterval = ref(null);
    const simulating = ref(false);

    const orderForm = reactive({
      fullName: '',
      phone: '',
      address: '',
      notes: '',
      paymentMethod: 'COD'
    });

    const initCheckout = async () => {
      // Direct back to cart if empty
      if (cartStore.items.length === 0) {
        cartStore.error = 'Giỏ hàng của bạn đang trống!';
        router.push('/cart');
        return;
      }

      // Populate user info
      if (authStore.user) {
        orderForm.fullName = authStore.user.fullName || '';
        orderForm.phone = authStore.user.phone || '';
        orderForm.address = authStore.user.address || '';
      }
      loading.value = false;
    };

    const handleCheckout = async () => {
      submitting.value = true;
      checkoutError.value = '';
      
      try {
        const payload = {
          fullName: orderForm.fullName,
          phone: orderForm.phone,
          address: orderForm.address,
          notes: orderForm.notes,
          paymentMethod: orderForm.paymentMethod,
          voucherCode: cartStore.appliedVoucher ? cartStore.appliedVoucher.code : null
        };

        const response = await axios.post('/api/orders', payload);
        const orderData = response.data;
        
        // Success: Clear applied voucher and cart state in UI
        cartStore.appliedVoucher = null;
        localStorage.removeItem('appliedVoucher');
        cartStore.items = [];

        if (payload.paymentMethod === 'BANK_TRANSFER') {
          currentOrder.value = orderData;
          // Generate free VietQR URL dynamically
          vietQrUrl.value = `https://img.vietqr.io/image/MB-0987654321-print.png?amount=${orderData.totalAmount}&addInfo=${orderData.orderCode}&accountName=TRENDIFY%20STORE`;
          showPaymentModal.value = true;

          // Start polling backend status every 3 seconds
          pollingInterval.value = setInterval(async () => {
            try {
              const checkRes = await axios.get('/api/orders/' + orderData.id);
              if (checkRes.data.paymentStatus === 'PAID') {
                clearInterval(pollingInterval.value);
                showPaymentModal.value = false;
                authStore.success = 'Thanh toán chuyển khoản thành công! Cảm ơn bạn.';
                setTimeout(() => {
                  router.push('/profile');
                }, 1500);
              }
            } catch (e) {
              console.error('Polling check error:', e);
            }
          }, 3000);
        } else {
          authStore.success = 'Đặt hàng thành công! Cảm ơn bạn đã ủng hộ Trendify.';
          router.push('/profile');
        }
      } catch (err) {
        checkoutError.value = err.response?.data?.message || 'Có lỗi xảy ra khi tạo đơn hàng. Vui lòng kiểm tra lại giỏ hàng.';
      } finally {
        submitting.value = false;
      }
    };

    const closePaymentModal = () => {
      if (pollingInterval.value) {
        clearInterval(pollingInterval.value);
      }
      showPaymentModal.value = false;
      // Still redirect to profile so they can view details or pay later
      router.push('/profile');
    };

    const triggerSimulatePayment = async () => {
      if (!currentOrder.value) return;
      simulating.value = true;
      try {
        await axios.post('/api/orders/simulate-payment/' + currentOrder.value.orderCode);
      } catch (err) {
        console.error('Lỗi giả lập thanh toán:', err);
      } finally {
        simulating.value = false;
      }
    };

    const formatCurrency = (val) => {
      if (!val) return '0đ';
      return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
    };

    onMounted(() => {
      initCheckout();
    });

    onUnmounted(() => {
      if (pollingInterval.value) {
        clearInterval(pollingInterval.value);
      }
    });

    return {
      cartStore,
      loading,
      submitting,
      checkoutError,
      orderForm,
      showPaymentModal,
      currentOrder,
      vietQrUrl,
      simulating,
      handleCheckout,
      closePaymentModal,
      triggerSimulatePayment,
      formatCurrency
    };
  }
};
</script>

<style scoped>
.checkout-page {
  padding: 60px 0;
}

.checkout-layout {
  display: grid;
  grid-template-columns: 1fr 400px;
  gap: 40px;
  align-items: start;
}

.billing-column h3, .summary-card h3 {
  font-size: 20px;
  margin-bottom: 24px;
  border-bottom: 2px solid var(--gray-light);
  padding-bottom: 12px;
}

/* Payment Option card style */
.payment-options {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.payment-option-card {
  display: flex;
  gap: 16px;
  padding: 16px;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  cursor: pointer;
  background: var(--white);
  transition: var(--transition);
}

.payment-option-card input {
  margin-top: 4px;
}

.payment-icon {
  font-size: 24px;
}

.payment-option-card strong {
  font-size: 15px;
  display: block;
  margin-bottom: 4px;
}

.payment-option-card p {
  font-size: 12px;
  color: var(--gray-dark);
}

.payment-option-card.active {
  border-color: var(--primary);
  background: #fdfbf7;
}

.submit-order-btn {
  width: 100%;
  margin-top: 24px;
}

/* Summary items mapping */
.order-items-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.order-item-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
}

.item-info {
  display: flex;
  flex-direction: column;
}

.item-name {
  font-weight: 600;
}

.item-specs {
  font-size: 12px;
  color: var(--gray);
}

.item-price {
  font-weight: 700;
}

.summary-divider {
  height: 1px;
  background: var(--border);
  margin: 16px 0;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  font-size: 15px;
  margin-bottom: 12px;
  color: var(--gray-dark);
}

.discount-val {
  color: #2ecc71;
  font-weight: 700;
}

.total-row {
  font-size: 18px;
  font-weight: 800;
  color: var(--dark);
}

.loader {
  text-align: center;
  padding: 80px 0;
  font-size: 18px;
}

/* VietQR Payment Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.qr-payment-modal {
  width: 480px;
  padding: 30px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  border-bottom: 2px solid var(--gray-light);
  padding-bottom: 10px;
}

.close-modal {
  background: transparent;
  border: none;
  font-size: 28px;
  cursor: pointer;
  color: var(--gray);
}

.qr-body {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.qr-instruction-title {
  font-size: 13px;
  color: var(--gray-dark);
  margin-bottom: 16px;
  text-align: center;
}

.qr-code-wrapper {
  background: white;
  padding: 12px;
  border-radius: var(--radius);
  border: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
  margin-bottom: 16px;
  width: 220px;
  height: 220px;
}

.qr-code-wrapper img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.qr-details {
  width: 100%;
  background: var(--gray-light);
  padding: 14px 18px;
  border-radius: var(--radius);
  margin-bottom: 16px;
  font-size: 13px;
  text-align: left;
}

.qr-details p {
  margin-bottom: 6px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price-txt {
  color: var(--primary);
  font-size: 15px;
}

.code-txt {
  color: var(--dark);
  font-family: monospace;
  font-size: 14px;
  background: #eae4d8;
  padding: 2px 8px;
  border-radius: 4px;
}

.polling-status {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: var(--gray-dark);
  margin-bottom: 20px;
  text-align: center;
}

.pulse-indicator {
  width: 10px;
  height: 10px;
  background-color: var(--primary);
  border-radius: 50%;
  box-shadow: 0 0 0 0 rgba(197, 168, 128, 0.7);
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(197, 168, 128, 0.7);
  }
  70% {
    transform: scale(1);
    box-shadow: 0 0 0 8px rgba(197, 168, 128, 0);
  }
  100% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(197, 168, 128, 0);
  }
}

.simulation-actions {
  width: 100%;
  border-top: 1px solid var(--border);
  padding-top: 16px;
}

.sim-btn {
  width: 100%;
  font-size: 12px;
}

.text-center {
  text-align: center;
}

.apipay-button-wrapper {
  margin-bottom: 20px;
  width: 100%;
}

.apipay-btn {
  display: block;
  width: 100%;
  padding: 14px;
  background-color: #2ecc71;
  color: white;
  text-decoration: none;
  font-weight: 700;
  border-radius: var(--radius);
  transition: var(--transition);
  text-align: center;
  box-shadow: 0 4px 6px rgba(46, 204, 113, 0.2);
}

.apipay-btn:hover {
  background-color: #27ae60;
  transform: translateY(-2px);
}

.apipay-hint {
  font-size: 12px;
  color: var(--gray-dark);
  margin-top: 14px;
  margin-bottom: 0;
}

@media (max-width: 992px) {
  .checkout-layout {
    grid-template-columns: 1fr;
  }
}
</style>

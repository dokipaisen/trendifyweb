<template>
  <div class="profile-page fade-in">
    <div class="container profile-container">
      <!-- Profile Navigation Tabs -->
      <aside class="profile-tabs card">
        <div class="profile-header">
          <div class="profile-avatar">
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
          </div>
          <h3>{{ authStore.user?.fullName }}</h3>
          <span class="badge badge-info">{{ authStore.user?.role }}</span>
        </div>
        <div class="tab-list">
          <button 
            :class="{ active: activeTab === 'info' }" 
            @click="activeTab = 'info'"
            class="tab-btn"
          >
            Thông tin cá nhân
          </button>
          <button 
            :class="{ active: activeTab === 'orders' }" 
            @click="activeTab = 'orders'"
            class="tab-btn"
          >
            Lịch sử đơn hàng
          </button>
          <button 
            :class="{ active: activeTab === 'password' }" 
            @click="activeTab = 'password'"
            class="tab-btn"
          >
            Đổi mật khẩu
          </button>
        </div>
      </aside>

      <!-- Profile Content Area -->
      <main class="profile-content">
        <!-- Success/Error alert banners -->
        <div v-if="authStore.success" class="alert alert-success">
          {{ authStore.success }}
        </div>
        <div v-if="authStore.error" class="alert alert-error">
          {{ authStore.error }}
        </div>

        <!-- TAB 1: User Info -->
        <div v-if="activeTab === 'info'" class="card tab-pane">
          <h2>Thông tin cá nhân</h2>
          <p class="tab-subtitle">Cập nhật thông tin tài khoản và địa chỉ giao hàng mặc định.</p>
          
          <form @submit.prevent="handleUpdateProfile">
            <div class="form-group">
              <label for="p-username">Tên đăng nhập (không thể thay đổi)</label>
              <input type="text" id="p-username" :value="authStore.user?.username" readonly class="form-control readonly-input">
            </div>

            <div class="form-group">
              <label for="p-fullName">Họ và tên *</label>
              <input type="text" id="p-fullName" v-model="profileForm.fullName" required class="form-control">
            </div>

            <div class="form-group">
              <label for="p-email">Địa chỉ Email *</label>
              <input type="email" id="p-email" v-model="profileForm.email" required class="form-control">
            </div>

            <div class="form-group">
              <label for="p-phone">Số điện thoại</label>
              <input type="tel" id="p-phone" v-model="profileForm.phone" class="form-control">
            </div>

            <div class="form-group">
              <label for="p-address">Địa chỉ giao hàng mặc định</label>
              <input type="text" id="p-address" v-model="profileForm.address" class="form-control">
            </div>

            <button type="submit" class="btn btn-primary" :disabled="authStore.loading">
              Lưu thay đổi
            </button>
          </form>
        </div>

        <!-- TAB 2: Order History -->
        <div v-if="activeTab === 'orders'" class="card tab-pane">
          <h2>Lịch sử mua hàng</h2>
          <p class="tab-subtitle">Theo dõi trạng thái và chi tiết các đơn hàng đã đặt.</p>

          <div v-if="ordersLoading" class="loader">Đang tải lịch sử mua hàng...</div>
          
          <div v-else-if="orders.length === 0" class="no-orders">
            <span class="no-orders-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
            </span>
            <p>Bạn chưa đặt đơn hàng nào trên Trendify.</p>
            <router-link to="/shop" class="btn btn-primary btn-sm">Mua sắm ngay</router-link>
          </div>

          <div v-else class="orders-list">
            <div class="order-card card" v-for="order in orders" :key="order.id">
              <div class="order-summary-row">
                <div>
                  <span class="order-code">{{ order.orderCode }}</span>
                  <p class="order-date">Đặt ngày: {{ formatDate(order.createdAt) }}</p>
                </div>

                <div class="text-right">
                  <span class="order-amount">{{ formatCurrency(order.totalAmount) }}</span>
                  <p class="payment-method">Thanh toán: {{ order.paymentMethod }}</p>
                </div>

                <div>
                  <span :class="getStatusClass(order.status)" class="badge">{{ getStatusLabel(order.status) }}</span>
                  <span :class="getPayStatusClass(order.paymentStatus)" class="badge badge-margin">{{ getPayStatusLabel(order.paymentStatus) }}</span>
                </div>

                <button @click="toggleOrderDetails(order)" class="btn btn-outline btn-sm detail-toggle-btn">
                  {{ order.expanded ? 'Thu gọn' : 'Xem chi tiết' }}
                </button>
              </div>

              <!-- Collapsible Order Details & Invoices -->
              <div v-if="order.expanded" class="order-expanded-details">
                <div class="details-divider"></div>
                
                <div class="delivery-details">
                  <h4>Thông tin người nhận</h4>
                  <p><strong>Người nhận:</strong> {{ order.fullName }}</p>
                  <p><strong>Số điện thoại:</strong> {{ order.phone }}</p>
                  <p><strong>Địa chỉ:</strong> {{ order.address }}</p>
                  <p v-if="order.notes"><strong>Ghi chú:</strong> {{ order.notes }}</p>
                </div>

                <div class="items-details">
                  <h4>Sản phẩm đã chọn</h4>
                  <div v-if="order.itemsLoading" class="loader-sm">Đang tải danh sách sản phẩm...</div>
                  <div v-else class="order-items-grid">
                    <div class="order-item-detail" v-for="item in order.items" :key="item.id">
                      <div class="item-img">
                        <img :src="item.productImageUrl || 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=100'" alt="Thumbnail">
                      </div>
                      <div class="item-info">
                        <strong>{{ item.productName }}</strong>
                        <span>Phân loại: {{ item.size }} / {{ item.color }}</span>
                        <span>Đơn giá: {{ formatCurrency(item.price) }} (x{{ item.quantity }})</span>
                      </div>
                      <span class="item-total">{{ formatCurrency(item.totalPrice) }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- TAB 3: Change Password -->
        <div v-if="activeTab === 'password'" class="card tab-pane">
          <h2>Đổi mật khẩu</h2>
          <p class="tab-subtitle">Bảo mật tài khoản của bạn bằng cách đổi mật khẩu định kỳ.</p>

          <form @submit.prevent="handleChangePassword">
            <div class="form-group">
              <label for="oldPassword">Mật khẩu hiện tại *</label>
              <input type="password" id="oldPassword" v-model="passwordForm.oldPassword" required class="form-control">
            </div>

            <div class="form-group">
              <label for="newPassword">Mật khẩu mới *</label>
              <input type="password" id="newPassword" v-model="passwordForm.newPassword" required class="form-control">
            </div>

            <div class="form-group">
              <label for="confirmPassword">Xác nhận mật khẩu mới *</label>
              <input type="password" id="confirmPassword" v-model="passwordForm.confirmPassword" required class="form-control">
            </div>

            <p v-if="passwordError" class="field-error-msg">{{ passwordError }}</p>

            <button type="submit" class="btn btn-primary" :disabled="authStore.loading">
              Đổi mật khẩu
            </button>
          </form>
        </div>
      </main>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted, watch } from 'vue';
import { useAuthStore } from '../stores/auth';
import axios from 'axios';

export default {
  name: 'ProfileView',
  setup() {
    const authStore = useAuthStore();
    const activeTab = ref('info');

    // Tab 1: Profile form
    const profileForm = reactive({
      fullName: '',
      email: '',
      phone: '',
      address: ''
    });

    // Tab 2: Change password form
    const passwordForm = reactive({
      oldPassword: '',
      newPassword: '',
      confirmPassword: ''
    });
    const passwordError = ref('');

    // Tab 3: Order History
    const orders = ref([]);
    const ordersLoading = ref(false);

    const initProfile = () => {
      if (authStore.user) {
        profileForm.fullName = authStore.user.fullName || '';
        profileForm.email = authStore.user.email || '';
        profileForm.phone = authStore.user.phone || '';
        profileForm.address = authStore.user.address || '';
      }
    };

    const handleUpdateProfile = async () => {
      try {
        await authStore.updateProfile({ ...profileForm });
      } catch (err) {
        console.error(err);
      }
    };

    const handleChangePassword = async () => {
      passwordError.value = '';
      if (passwordForm.newPassword !== passwordForm.confirmPassword) {
        passwordError.value = 'Mật khẩu xác nhận không trùng khớp.';
        return;
      }
      try {
        await authStore.changePassword(passwordForm.oldPassword, passwordForm.newPassword);
        // Clear fields
        passwordForm.oldPassword = '';
        passwordForm.newPassword = '';
        passwordForm.confirmPassword = '';
      } catch (err) {
        console.error(err);
      }
    };

    const fetchOrders = async () => {
      ordersLoading.value = true;
      try {
        const response = await axios.get('/api/orders');
        orders.value = response.data.map(order => ({ ...order, expanded: false, items: [], itemsLoading: false }));
      } catch (err) {
        console.error('Lỗi tải đơn hàng:', err);
      } finally {
        ordersLoading.value = false;
      }
    };

    const toggleOrderDetails = async (order) => {
      order.expanded = !order.expanded;
      if (order.expanded && order.items.length === 0) {
        order.itemsLoading = true;
        try {
          const res = await axios.get(`/api/orders/${order.id}`);
          order.items = res.data.items || [];
        } catch (err) {
          console.error(err);
        } finally {
          order.itemsLoading = false;
        }
      }
    };

    const getStatusLabel = (status) => {
      const labels = {
        'PENDING': 'Chờ xác nhận',
        'CONFIRMED': 'Đã xác nhận',
        'PROCESSING': 'Đang chuẩn bị hàng',
        'SHIPPING': 'Đang giao hàng',
        'DELIVERED': 'Đã giao thành công',
        'CANCELLED': 'Đã huỷ đơn'
      };
      return labels[status] || status;
    };

    const getStatusClass = (status) => {
      const classes = {
        'PENDING': 'badge-warning',
        'CONFIRMED': 'badge-info',
        'PROCESSING': 'badge-info',
        'SHIPPING': 'badge-info',
        'DELIVERED': 'badge-success',
        'CANCELLED': 'badge-danger'
      };
      return classes[status] || 'badge-info';
    };

    const getPayStatusLabel = (payStatus) => {
      return payStatus === 'PAID' ? 'Đã thanh toán' : 'Chưa thanh toán';
    };

    const getPayStatusClass = (payStatus) => {
      return payStatus === 'PAID' ? 'badge-success' : 'badge-danger';
    };

    const formatCurrency = (val) => {
      if (!val) return '0đ';
      return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
    };

    const formatDate = (dateStr) => {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString('vi-VN', { year: 'numeric', month: '2-digit', day: '2-digit' });
    };

    onMounted(() => {
      initProfile();
      fetchOrders();
    });

    watch(() => activeTab.value, (newTab) => {
      authStore.clearMessages();
      if (newTab === 'orders') {
        fetchOrders();
      }
    });

    return {
      authStore,
      activeTab,
      profileForm,
      passwordForm,
      passwordError,
      orders,
      ordersLoading,
      handleUpdateProfile,
      handleChangePassword,
      toggleOrderDetails,
      getStatusLabel,
      getStatusClass,
      getPayStatusLabel,
      getPayStatusClass,
      formatCurrency,
      formatDate
    };
  }
};
</script>

<style scoped>
.profile-page {
  padding: 60px 0;
}

.profile-container {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 40px;
  align-items: start;
}

/* Tabs Sidebar styling */
.profile-tabs {
  padding: 30px 20px;
  background: var(--white);
  text-align: center;
}

.profile-header {
  margin-bottom: 30px;
}

.profile-avatar {
  font-size: 54px;
  background: var(--gray-light);
  width: 90px;
  height: 90px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px auto;
  border: 2px solid var(--primary);
}

.profile-header h3 {
  font-size: 18px;
  margin-bottom: 6px;
}

.tab-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.tab-btn {
  text-align: left;
  border: none;
  background: transparent;
  padding: 12px 16px;
  font-size: 14px;
  font-weight: 600;
  color: var(--gray-dark);
  border-radius: var(--radius-sm);
  width: 100%;
}

.tab-btn:hover {
  background: var(--gray-light);
  color: var(--primary);
}

.tab-btn.active {
  background: #fdfbf7;
  color: var(--primary);
  border-left: 4px solid var(--primary);
  border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
}

/* Content Area styling */
.tab-pane h2 {
  font-size: 22px;
  margin-bottom: 6px;
}

.tab-subtitle {
  color: var(--gray);
  font-size: 14px;
  margin-bottom: 30px;
}

.readonly-input {
  background-color: var(--gray-light);
  cursor: not-allowed;
}

.field-error-msg {
  color: #e74c3c;
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 16px;
}

/* Orders Tab list styling */
.orders-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.order-card {
  padding: 20px;
  border: 1px solid rgba(197, 168, 128, 0.08);
}

.order-summary-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
}

.order-code {
  font-weight: 800;
  font-family: var(--font-heading);
  font-size: 16px;
  color: var(--dark);
}

.order-date {
  font-size: 12px;
  color: var(--gray);
}

.order-amount {
  font-weight: 700;
  font-size: 16px;
  color: var(--primary);
}

.payment-method {
  font-size: 12px;
  color: var(--gray-dark);
}

.badge-margin {
  margin-left: 8px;
}

.detail-toggle-btn {
  padding: 8px 16px;
}

/* Order Details Drawer styling */
.order-expanded-details {
  animation: fadeIn 0.3s ease;
}

.details-divider {
  height: 1px;
  background: var(--border);
  margin: 16px 0;
}

.delivery-details {
  margin-bottom: 20px;
  font-size: 14px;
  background: #faf8f5;
  padding: 16px;
  border-radius: var(--radius);
}

.delivery-details h4, .items-details h4 {
  font-size: 15px;
  margin-bottom: 12px;
  color: var(--primary);
}

.delivery-details p {
  margin-bottom: 6px;
}

.order-items-grid {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.order-item-detail {
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 13px;
}

.item-img {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  background: var(--gray-light);
  border: 1px solid var(--border);
}

.item-img img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.order-item-detail .item-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.item-total {
  font-weight: 700;
  color: var(--dark);
}

.no-orders {
  text-align: center;
  padding: 40px;
}

.no-orders-icon {
  font-size: 48px;
  margin-bottom: 16px;
  display: block;
}

.no-orders p {
  color: var(--gray);
  margin-bottom: 16px;
}

.loader {
  text-align: center;
  padding: 40px;
}

.loader-sm {
  text-align: center;
  padding: 20px 0;
  font-size: 13px;
  color: var(--gray);
}

@media (max-width: 992px) {
  .profile-container {
    grid-template-columns: 1fr;
  }
}
</style>

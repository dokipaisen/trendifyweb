<template>
  <div class="order-mgmt-page fade-in">
    <div class="page-header">
      <h1>Quản lý Đơn hàng</h1>
      <p>Lọc danh sách đơn hàng, xem chi tiết hóa đơn và cập nhật trạng thái vận chuyển.</p>
    </div>

    <!-- Filter Widget -->
    <div class="card filter-card">
      <div class="filter-grid">
        <div class="form-group">
          <label>Từ ngày</label>
          <input type="date" v-model="filters.startDate" class="form-control" @change="fetchOrders">
        </div>
        <div class="form-group">
          <label>Đến ngày</label>
          <input type="date" v-model="filters.endDate" class="form-control" @change="fetchOrders">
        </div>
        <div class="form-group">
          <label>Tháng</label>
          <select v-model.number="filters.month" class="form-control" @change="fetchOrders">
            <option :value="null">Tất cả tháng</option>
            <option v-for="m in 12" :key="m" :value="m">Tháng {{ m }}</option>
          </select>
        </div>
        <div class="form-group">
          <label>Năm</label>
          <select v-model.number="filters.year" class="form-control" @change="fetchOrders">
            <option :value="null">Tất cả năm</option>
            <option v-for="y in [2024, 2025, 2026]" :key="y" :value="y">Năm {{ y }}</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Orders Table -->
    <div class="card table-card">
      <div v-if="loading" class="loader">Đang tải đơn hàng...</div>
      
      <div v-else class="table-wrapper">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Mã Đơn hàng</th>
              <th>Ngày đặt</th>
              <th>Khách hàng</th>
              <th>Số điện thoại</th>
              <th>Tổng tiền</th>
              <th>Thanh toán</th>
              <th>Trạng thái</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="orders.length === 0">
              <td colspan="8" class="text-center text-gray">Không tìm thấy đơn hàng nào.</td>
            </tr>
            <tr v-else v-for="order in orders" :key="order.id">
              <td><strong>{{ order.orderCode }}</strong></td>
              <td>{{ formatDate(order.createdAt) }}</td>
              <td>{{ order.fullName }}</td>
              <td>{{ order.phone }}</td>
              <td class="gold-bold">{{ formatCurrency(order.totalAmount) }}</td>
              <td>
                <span class="badge" :class="order.paymentStatus === 'PAID' ? 'badge-success' : 'badge-danger'">
                  {{ order.paymentStatus === 'PAID' ? 'Đã thanh toán' : 'Chưa thanh toán' }}
                </span>
              </td>
              <td>
                <span class="badge" :class="getStatusClass(order.status)">
                  {{ getStatusLabel(order.status) }}
                </span>
              </td>
              <td>
                <button @click="openStatusModal(order)" class="btn btn-outline btn-sm">
                  Cập nhật
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Update Status Modal -->
    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content card">
        <div class="modal-header">
          <h2>Cập nhật đơn hàng: {{ selectedOrder?.orderCode }}</h2>
          <button @click="showModal = false" class="close-modal">&times;</button>
        </div>

        <div class="modal-body-scroll" v-if="selectedOrder">
          <!-- Receipient info summary -->
          <div class="info-block">
            <h4>Thông tin giao hàng</h4>
            <p><strong>Người nhận:</strong> {{ selectedOrder.fullName }}</p>
            <p><strong>Số điện thoại:</strong> {{ selectedOrder.phone }}</p>
            <p><strong>Địa chỉ:</strong> {{ selectedOrder.address }}</p>
            <p v-if="selectedOrder.notes"><strong>Ghi chú:</strong> {{ selectedOrder.notes }}</p>
          </div>

          <!-- Items list -->
          <div class="info-block">
            <h4>Sản phẩm đã chọn</h4>
            <div v-if="orderItemsLoading" class="loader-sm">Đang tải sản phẩm...</div>
            <div v-else class="order-items-summary-list">
              <div class="order-item-summary" v-for="item in selectedOrderItems" :key="item.id">
                <span>{{ item.productName }} ({{ item.size }} / {{ item.color }}) x{{ item.quantity }}</span>
                <strong>{{ formatCurrency(item.totalPrice) }}</strong>
              </div>
            </div>
          </div>

          <!-- Form status selectors -->
          <form @submit.prevent="saveOrderStatus" class="status-form">
            <div class="form-group">
              <label for="m-status">Trạng thái vận chuyển</label>
              <select id="m-status" v-model="statusForm.status" class="form-control">
                <option value="PENDING">PENDING (Chờ xác nhận)</option>
                <option value="CONFIRMED">CONFIRMED (Đã xác nhận)</option>
                <option value="PROCESSING">PROCESSING (Đang chuẩn bị hàng)</option>
                <option value="SHIPPING">SHIPPING (Đang giao hàng)</option>
                <option value="DELIVERED">DELIVERED (Đã giao thành công)</option>
                <option value="CANCELLED">CANCELLED (Hủy đơn hàng)</option>
              </select>
            </div>

            <div class="form-group">
              <label for="m-payStatus">Trạng thái thanh toán</label>
              <select id="m-payStatus" v-model="statusForm.paymentStatus" class="form-control">
                <option value="UNPAID">UNPAID (Chưa thanh toán)</option>
                <option value="PAID">PAID (Đã thanh toán)</option>
              </select>
            </div>

            <div class="modal-actions">
              <button type="button" @click="showModal = false" class="btn btn-outline">Quay lại</button>
              <button type="submit" class="btn btn-primary">Lưu cập nhật</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue';
import axios from 'axios';

export default {
  name: 'OrderManagementView',
  setup() {
    const orders = ref([]);
    const loading = ref(true);
    
    const showModal = ref(false);
    const selectedOrder = ref(null);
    const selectedOrderItems = ref([]);
    const orderItemsLoading = ref(false);

    const filters = reactive({
      startDate: '',
      endDate: '',
      month: null,
      year: new Date().getFullYear()
    });

    const statusForm = reactive({
      status: '',
      paymentStatus: ''
    });

    const fetchOrders = async () => {
      loading.value = true;
      try {
        const params = {};
        if (filters.startDate) params.startDate = filters.startDate;
        if (filters.endDate) params.endDate = filters.endDate;
        if (filters.month) params.month = filters.month;
        if (filters.year) params.year = filters.year;

        const response = await axios.get('/api/admin/orders', { params });
        orders.value = response.data;
      } catch (err) {
        console.error(err);
      } finally {
        loading.value = false;
      }
    };

    const openStatusModal = async (order) => {
      selectedOrder.value = order;
      statusForm.status = order.status;
      statusForm.paymentStatus = order.paymentStatus;
      showModal.value = true;
      
      orderItemsLoading.value = true;
      try {
        // Fetch order details including item list
        const res = await axios.get(`/api/orders/${order.id}`);
        selectedOrderItems.value = res.data.items || [];
      } catch (err) {
        console.error(err);
      } finally {
        orderItemsLoading.value = false;
      }
    };

    const saveOrderStatus = async () => {
      try {
        await axios.put(`/api/admin/orders/${selectedOrder.value.id}/status?status=${statusForm.status}&paymentStatus=${statusForm.paymentStatus}`);
        showModal.value = false;
        fetchOrders();
      } catch (err) {
        console.error(err);
        alert('Cập nhật trạng thái đơn hàng thất bại.');
      }
    };

    const getStatusLabel = (status) => {
      const labels = {
        'PENDING': 'Chờ xác nhận',
        'CONFIRMED': 'Đã xác nhận',
        'PROCESSING': 'Đang soạn hàng',
        'SHIPPING': 'Đang giao hàng',
        'DELIVERED': 'Giao thành công',
        'CANCELLED': 'Hủy đơn'
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
      fetchOrders();
    });

    return {
      orders,
      loading,
      filters,
      showModal,
      selectedOrder,
      selectedOrderItems,
      orderItemsLoading,
      statusForm,
      openStatusModal,
      saveOrderStatus,
      getStatusLabel,
      getStatusClass,
      formatCurrency,
      formatDate,
      fetchOrders
    };
  }
};
</script>

<style scoped>
.page-header {
  margin-bottom: 30px;
}

.page-header h1 {
  font-size: 28px;
  margin-bottom: 4px;
}

.page-header p {
  color: var(--gray);
}

.filter-card {
  margin-bottom: 30px;
}

.filter-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

/* Modal updates */
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

.modal-content {
  width: 600px;
  max-height: 85vh;
  display: flex;
  flex-direction: column;
  padding: 30px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  border-bottom: 2px solid var(--gray-light);
  padding-bottom: 12px;
}

.close-modal {
  background: transparent;
  border: none;
  font-size: 28px;
  cursor: pointer;
  padding: 0;
  color: var(--gray);
}

.modal-body-scroll {
  overflow-y: auto;
  flex: 1;
}

.info-block {
  margin-bottom: 24px;
  background: var(--gray-light);
  padding: 16px;
  border-radius: var(--radius);
  font-size: 14px;
}

.info-block h4 {
  font-size: 14px;
  color: var(--primary);
  margin-bottom: 10px;
  text-transform: uppercase;
}

.info-block p {
  margin-bottom: 4px;
}

.order-items-summary-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.order-item-summary {
  display: flex;
  justify-content: space-between;
  border-bottom: 1px solid var(--border);
  padding-bottom: 6px;
}

.order-item-summary:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 24px;
}

.text-center { text-align: center; }
.text-gray { color: var(--gray); }

.loader {
  text-align: center;
  padding: 40px;
}

.loader-sm {
  text-align: center;
  padding: 10px 0;
  color: var(--gray);
}
</style>

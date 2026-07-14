<template>
  <div class="promo-mgmt-page fade-in">
    <div class="page-header-row">
      <div>
        <h1>Quản lý Khuyến mãi & Vouchers</h1>
        <p>Tạo và quản lý các mã giảm giá áp dụng cho khách hàng.</p>
      </div>
      <button @click="openCreateModal" class="btn btn-primary">Tạo voucher mới</button>
    </div>

    <!-- Promotions Table -->
    <div class="card table-card">
      <div v-if="loading" class="loader">Đang tải danh sách khuyến mãi...</div>
      
      <div v-else class="table-wrapper">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Mã Code</th>
              <th>Loại giảm giá</th>
              <th>Giá trị</th>
              <th>Đơn hàng tối thiểu</th>
              <th>Giảm tối đa</th>
              <th>Thời hạn</th>
              <th>Trạng thái</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="promotions.length === 0">
              <td colspan="8" class="text-center text-gray">Chưa có mã giảm giá nào được tạo.</td>
            </tr>
            <tr v-else v-for="promo in promotions" :key="promo.id">
              <td><strong><code>{{ promo.code }}</code></strong></td>
              <td>{{ promo.discountType === 'PERCENTAGE' ? 'Phần trăm (%)' : 'Số tiền cụ thể (đ)' }}</td>
              <td class="gold-bold">
                {{ promo.discountType === 'PERCENTAGE' ? promo.discountValue + '%' : formatCurrency(promo.discountValue) }}
              </td>
              <td>{{ formatCurrency(promo.minOrderValue) }}</td>
              <td>{{ promo.maxDiscount ? formatCurrency(promo.maxDiscount) : 'Không giới hạn' }}</td>
              <td>
                <span class="expiry-txt">
                  Từ: {{ formatDate(promo.startDate) }}<br>
                  Đến: {{ formatDate(promo.endDate) }}
                </span>
              </td>
              <td>
                <span class="badge" :class="promo.active ? 'badge-success' : 'badge-danger'">
                  {{ promo.active ? 'Kích hoạt' : 'Tạm dừng' }}
                </span>
              </td>
              <td>
                <div class="actions-group">
                  <button @click="openEditModal(promo)" class="btn-action edit-btn">Sửa</button>
                  <button @click="handleDeletePromotion(promo.id)" class="btn-action delete-btn">Xoá</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal Form (Create / Edit) -->
    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content card">
        <div class="modal-header">
          <h2>{{ isEditMode ? 'Cập nhật Voucher' : 'Tạo Voucher mới' }}</h2>
          <button @click="showModal = false" class="close-modal">&times;</button>
        </div>

        <form @submit.prevent="savePromotion" class="modal-form">
          <div class="form-group">
            <label for="m-code">Mã giảm giá (Code) *</label>
            <input 
              type="text" 
              id="m-code" 
              v-model="promoForm.code" 
              required 
              placeholder="ví dụ: SUMMER26, TRENDIFY50..."
              class="form-control"
              :disabled="isEditMode"
            >
          </div>

          <div class="form-group">
            <label for="m-type">Loại giảm giá *</label>
            <select id="m-type" v-model="promoForm.discountType" required class="form-control">
              <option value="PERCENTAGE">PERCENTAGE (Phần trăm đơn hàng)</option>
              <option value="FIXED_AMOUNT">FIXED_AMOUNT (Số tiền cụ thể)</option>
            </select>
          </div>

          <div class="form-group">
            <label for="m-val">Giá trị giảm giá *</label>
            <input type="number" id="m-val" v-model.number="promoForm.discountValue" required class="form-control">
          </div>

          <div class="form-group">
            <label for="m-minVal">Giá trị đơn hàng tối thiểu *</label>
            <input type="number" id="m-minVal" v-model.number="promoForm.minOrderValue" required class="form-control">
          </div>

          <div class="form-group" v-if="promoForm.discountType === 'PERCENTAGE'">
            <label for="m-maxDisc">Số tiền giảm tối đa</label>
            <input type="number" id="m-maxDisc" v-model.number="promoForm.maxDiscount" class="form-control" placeholder="Để trống nếu không giới hạn...">
          </div>

          <div class="form-group">
            <label for="m-start">Ngày bắt đầu hiệu lực</label>
            <input type="datetime-local" id="m-start" v-model="promoForm.startDate" class="form-control">
          </div>

          <div class="form-group">
            <label for="m-end">Ngày hết hạn</label>
            <input type="datetime-local" id="m-end" v-model="promoForm.endDate" class="form-control">
          </div>

          <div class="form-group checkbox-group">
            <label class="checkbox-label">
              <input type="checkbox" v-model="promoForm.active">
              Kích hoạt hoạt động
            </label>
          </div>

          <div class="modal-actions">
            <button type="button" @click="showModal = false" class="btn btn-outline">Huỷ bỏ</button>
            <button type="submit" class="btn btn-primary">Lưu mã giảm giá</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue';
import axios from 'axios';

export default {
  name: 'PromotionManagementView',
  setup() {
    const promotions = ref([]);
    const loading = ref(true);
    
    const showModal = ref(false);
    const isEditMode = ref(false);
    const editId = ref(null);

    const promoForm = reactive({
      code: '',
      discountType: 'PERCENTAGE',
      discountValue: '',
      minOrderValue: 0,
      maxDiscount: '',
      startDate: '',
      endDate: '',
      active: true
    });

    const fetchPromotions = async () => {
      loading.value = true;
      try {
        const response = await axios.get('/api/admin/promotions');
        promotions.value = response.data;
      } catch (err) {
        console.error('Lỗi tải khuyến mãi:', err);
      } finally {
        loading.value = false;
      }
    };

    const openCreateModal = () => {
      isEditMode.value = false;
      editId.value = null;
      promoForm.code = '';
      promoForm.discountType = 'PERCENTAGE';
      promoForm.discountValue = '';
      promoForm.minOrderValue = 0;
      promoForm.maxDiscount = '';
      promoForm.startDate = '';
      promoForm.endDate = '';
      promoForm.active = true;
      showModal.value = true;
    };

    const openEditModal = (promo) => {
      isEditMode.value = true;
      editId.value = promo.id;
      promoForm.code = promo.code;
      promoForm.discountType = promo.discountType;
      promoForm.discountValue = promo.discountValue;
      promoForm.minOrderValue = promo.minOrderValue || 0;
      promoForm.maxDiscount = promo.maxDiscount || '';
      
      // Format timestamps for local datetime input
      promoForm.startDate = promo.startDate ? promo.startDate.substring(0, 16) : '';
      promoForm.endDate = promo.endDate ? promo.endDate.substring(0, 16) : '';
      
      promoForm.active = promo.active;
      showModal.value = true;
    };

    const savePromotion = async () => {
      try {
        // Build payload converting empty inputs properly
        const payload = {
          code: promoForm.code,
          discountType: promoForm.discountType,
          discountValue: promoForm.discountValue,
          minOrderValue: promoForm.minOrderValue,
          maxDiscount: promoForm.maxDiscount || null,
          startDate: promoForm.startDate ? promoForm.startDate + ':00' : null,
          endDate: promoForm.endDate ? promoForm.endDate + ':00' : null,
          active: promoForm.active
        };

        if (isEditMode.value) {
          await axios.put(`/api/admin/promotions/${editId.value}`, payload);
        } else {
          await axios.post('/api/admin/promotions', payload);
        }

        showModal.value = false;
        fetchPromotions();
      } catch (err) {
        console.error(err);
        alert(err.response?.data?.message || 'Lỗi lưu khuyến mãi.');
      }
    };

    const handleDeletePromotion = async (id) => {
      if (confirm('Bạn có chắc chắn muốn xoá mã giảm giá này?')) {
        try {
          await axios.delete(`/api/admin/promotions/${id}`);
          fetchPromotions();
        } catch (err) {
          console.error(err);
        }
      }
    };

    const formatCurrency = (val) => {
      if (!val) return '0đ';
      return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
    };

    const formatDate = (dateStr) => {
      if (!dateStr) return 'Vô hạn';
      const d = new Date(dateStr);
      return d.toLocaleDateString('vi-VN', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
    };

    onMounted(() => {
      fetchPromotions();
    });

    return {
      promotions,
      loading,
      showModal,
      isEditMode,
      promoForm,
      openCreateModal,
      openEditModal,
      savePromotion,
      handleDeletePromotion,
      formatCurrency,
      formatDate
    };
  }
};
</script>

<style scoped>
.page-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.page-header-row h1 {
  font-size: 28px;
  margin-bottom: 4px;
}

.page-header-row p {
  color: var(--gray);
}

.expiry-txt {
  font-size: 11px;
  color: var(--gray-dark);
}

.actions-group {
  display: flex;
  gap: 12px;
}

.btn-action {
  border: none;
  background: transparent;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
}

.edit-btn {
  color: #3498db;
}

.delete-btn {
  color: #e74c3c;
}

/* Modal styling */
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
  width: 500px;
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

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 24px;
}

.checkbox-group {
  margin-top: 10px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
}

.text-center { text-align: center; }
.text-gray { color: var(--gray); }

.loader {
  text-align: center;
  padding: 40px;
}
</style>

<template>
  <div class="banner-mgmt-page fade-in">
    <div class="page-header-row">
      <div>
        <h1>Quản lý Banner Quảng cáo</h1>
        <p>Quản lý hình ảnh và liên kết của các Banner trình chiếu trên trang chủ.</p>
      </div>
      <button @click="openCreateModal" class="btn btn-primary">Thêm Banner mới</button>
    </div>

    <!-- Banners Table -->
    <div class="card table-card">
      <div v-if="loading" class="loader">Đang tải danh sách banner...</div>
      
      <div v-else class="table-wrapper">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Thứ tự</th>
              <th>Xem trước</th>
              <th>Tiêu đề Banner</th>
              <th>Liên kết (Link URL)</th>
              <th>Trạng thái</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="banners.length === 0">
              <td colspan="6" class="text-center text-gray">Chưa có banner nào được tạo.</td>
            </tr>
            <tr v-else v-for="b in banners" :key="b.id">
              <td><strong>#{{ b.displayOrder ?? 0 }}</strong></td>
              <td>
                <img 
                  :src="b.imageUrl" 
                  :alt="b.title" 
                  class="banner-preview"
                  @error="$event.target.src='https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&auto=format&fit=crop'"
                >
              </td>
              <td>
                <strong>{{ b.title || '(Không có tiêu đề)' }}</strong>
              </td>
              <td>
                <span class="url-txt">{{ b.linkUrl || '/shop' }}</span>
              </td>
              <td>
                <span class="badge" :class="b.active ? 'badge-success' : 'badge-danger'">
                  {{ b.active ? 'Hiển thị' : 'Ẩn' }}
                </span>
              </td>
              <td>
                <div class="actions-group">
                  <button @click="openEditModal(b)" class="btn-action edit-btn">Sửa</button>
                  <button @click="handleDeleteBanner(b.id)" class="btn-action delete-btn">Xoá</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal Form (Create / Edit) -->
    <Teleport to="body">
      <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
        <div class="modal-content card">
          <div class="modal-header">
            <h2>{{ isEditMode ? 'Cập nhật Banner' : 'Thêm Banner mới' }}</h2>
            <button @click="showModal = false" class="close-modal">&times;</button>
          </div>

          <form @submit.prevent="saveBanner" class="modal-form">
            <div class="form-group">
              <label for="m-title">Tiêu đề Banner</label>
              <input 
                type="text" 
                id="m-title" 
                v-model="bannerForm.title" 
                placeholder="ví dụ: BỘ SƯU TẬP MÙA HÈ 2026..."
                class="form-control"
              >
            </div>

            <!-- Image Upload & URL input -->
            <div class="form-group">
              <label>Hình ảnh Banner *</label>
              <div class="image-upload-wrapper">
                <div class="img-preview" v-if="bannerForm.imageUrl">
                  <img :src="bannerForm.imageUrl" alt="Preview">
                  <button type="button" @click="bannerForm.imageUrl = ''" class="remove-preview-btn" title="Xóa ảnh">&times;</button>
                </div>
                <div class="upload-trigger" v-else>
                  <input type="file" @change="uploadBannerImage" accept="image/*" class="file-input-hide" id="banner-img-upload">
                  <label for="banner-img-upload" class="upload-label">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                    <span>Tải ảnh lên từ máy tính</span>
                  </label>
                </div>
                <p v-if="uploading" class="uploading-text">Đang tải ảnh lên...</p>
              </div>
              
              <div class="url-input-fallback">
                <small>Hoặc nhập URL / Đường dẫn ảnh trực tiếp:</small>
                <input 
                  type="text" 
                  v-model="bannerForm.imageUrl" 
                  required 
                  placeholder="http://... hoặc /uploads/..."
                  class="form-control"
                >
              </div>
            </div>

            <div class="form-group">
              <label for="m-linkUrl">Đường dẫn chuyển hướng (Link URL)</label>
              <input 
                type="text" 
                id="m-linkUrl" 
                v-model="bannerForm.linkUrl" 
                placeholder="ví dụ: /shop hoặc /products/1"
                class="form-control"
              >
            </div>

            <div class="form-group">
              <label for="m-displayOrder">Thứ tự hiển thị</label>
              <input 
                type="number" 
                id="m-displayOrder" 
                v-model.number="bannerForm.displayOrder" 
                class="form-control"
              >
            </div>

            <div class="form-group checkbox-group">
              <label>
                <input type="checkbox" v-model="bannerForm.active">
                Kích hoạt (Hiển thị trên trang chủ)
              </label>
            </div>

            <div v-if="errorMessage" class="error-msg">{{ errorMessage }}</div>

            <div class="modal-footer">
              <button type="button" @click="showModal = false" class="btn btn-outline">Hủy</button>
              <button type="submit" class="btn btn-primary" :disabled="submitting || uploading">
                {{ submitting ? 'Đang lưu...' : (isEditMode ? 'Cập nhật' : 'Tạo mới') }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue';
import axios from 'axios';

export default {
  name: 'BannerManagementView',
  setup() {
    const banners = ref([]);
    const loading = ref(true);
    const showModal = ref(false);
    const isEditMode = ref(false);
    const submitting = ref(false);
    const uploading = ref(false);
    const errorMessage = ref('');
    const currentId = ref(null);

    const bannerForm = reactive({
      title: '',
      imageUrl: '',
      linkUrl: '',
      displayOrder: 0,
      active: true
    });

    const fetchBanners = async () => {
      loading.value = true;
      try {
        const res = await axios.get('/api/admin/banners', { withCredentials: true });
        banners.value = res.data;
      } catch (err) {
        console.error('Lỗi tải danh sách banner:', err);
      } finally {
        loading.value = false;
      }
    };

    const uploadBannerImage = async (event) => {
      const file = event.target.files[0];
      if (!file) return;

      const formData = new FormData();
      formData.append('file', file);
      
      uploading.value = true;
      try {
        const response = await axios.post('/api/admin/upload', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
          withCredentials: true
        });
        bannerForm.imageUrl = response.data.url;
      } catch (err) {
        console.error('Lỗi upload ảnh:', err);
        alert('Tải ảnh lên thất bại!');
      } finally {
        uploading.value = false;
      }
    };

    const openCreateModal = () => {
      isEditMode.value = false;
      currentId.value = null;
      errorMessage.value = '';
      bannerForm.title = '';
      bannerForm.imageUrl = '';
      bannerForm.linkUrl = '/shop';
      bannerForm.displayOrder = banners.value.length + 1;
      bannerForm.active = true;
      showModal.value = true;
    };

    const openEditModal = (b) => {
      isEditMode.value = true;
      currentId.value = b.id;
      errorMessage.value = '';
      bannerForm.title = b.title || '';
      bannerForm.imageUrl = b.imageUrl || '';
      bannerForm.linkUrl = b.linkUrl || '/shop';
      bannerForm.displayOrder = b.displayOrder ?? 0;
      bannerForm.active = b.active ?? true;
      showModal.value = true;
    };

    const saveBanner = async () => {
      submitting.value = true;
      errorMessage.value = '';

      try {
        const payload = {
          title: bannerForm.title,
          imageUrl: bannerForm.imageUrl,
          linkUrl: bannerForm.linkUrl,
          displayOrder: bannerForm.displayOrder,
          active: bannerForm.active
        };

        if (isEditMode.value) {
          await axios.put(`/api/admin/banners/${currentId.value}`, payload, { withCredentials: true });
        } else {
          await axios.post('/api/admin/banners', payload, { withCredentials: true });
        }

        showModal.value = false;
        fetchBanners();
      } catch (err) {
        errorMessage.value = err.response?.data?.message || 'Không thể lưu Banner. Vui lòng thử lại.';
      } finally {
        submitting.value = false;
      }
    };

    const handleDeleteBanner = async (id) => {
      if (!confirm('Bạn có chắc chắn muốn xoá Banner này?')) return;
      try {
        await axios.delete(`/api/admin/banners/${id}`, { withCredentials: true });
        fetchBanners();
      } catch (err) {
        alert(err.response?.data?.message || 'Xoá thất bại.');
      }
    };

    onMounted(() => {
      fetchBanners();
    });

    return {
      banners,
      loading,
      showModal,
      isEditMode,
      submitting,
      uploading,
      errorMessage,
      bannerForm,
      uploadBannerImage,
      openCreateModal,
      openEditModal,
      saveBanner,
      handleDeleteBanner
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

.table-card {
  padding: 0;
  overflow: hidden;
}

.banner-preview {
  width: 120px;
  height: 60px;
  object-fit: cover;
  border-radius: var(--radius-sm);
  border: 1px solid var(--border);
}

.url-txt {
  font-family: monospace;
  font-size: 13px;
  color: var(--gray);
}

.actions-group {
  display: flex;
  gap: 8px;
}

.btn-action {
  padding: 6px 12px;
  border-radius: var(--radius-sm);
  border: none;
  font-weight: 600;
  font-size: 13px;
  cursor: pointer;
}

.edit-btn {
  background-color: #f39c12;
  color: white;
}

.delete-btn {
  background-color: #e74c3c;
  color: white;
}

.badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 700;
}

.badge-success {
  background-color: #e8f8f5;
  color: #2ecc71;
}

.badge-danger {
  background-color: #fadbd8;
  color: #e74c3c;
}

/* Image Upload Component Styles */
.image-upload-wrapper {
  margin-bottom: 10px;
}

.img-preview {
  position: relative;
  width: 100%;
  height: 140px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  border: 1px solid var(--border);
  background-color: #f8f9fa;
}

.img-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.remove-preview-btn {
  position: absolute;
  top: 8px;
  right: 8px;
  background: rgba(231, 76, 60, 0.9);
  color: white;
  border: none;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.file-input-hide {
  display: none;
}

.upload-label {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 24px;
  border: 2px dashed #ccc;
  border-radius: var(--radius-sm);
  background: #fafafa;
  cursor: pointer;
  color: #666;
  transition: all 0.2s ease;
}

.upload-label:hover {
  border-color: var(--primary);
  color: var(--primary);
  background: #fffdf5;
}

.uploading-text {
  font-size: 13px;
  color: var(--primary);
  margin-top: 6px;
  font-weight: 600;
}

.url-input-fallback small {
  display: block;
  color: var(--gray);
  margin-bottom: 4px;
  font-size: 12px;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(0, 0, 0, 0.65);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 99999;
  padding: 20px;
  box-sizing: border-box;
}

.modal-content {
  width: 100%;
  max-width: 520px;
  max-height: 85vh;
  background: #ffffff;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.3);
  overflow-y: auto;
  position: relative;
  margin: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.close-modal {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
}

.modal-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.checkbox-group label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-weight: 600;
}

.error-msg {
  color: #e74c3c;
  font-size: 14px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 20px;
}
</style>

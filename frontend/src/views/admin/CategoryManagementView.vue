<template>
  <div class="category-mgmt-page fade-in">
    <div class="page-header-row">
      <div>
        <h1>Quản lý Danh mục Sản phẩm</h1>
        <p>Thêm, sửa hoặc xoá các danh mục phân loại sản phẩm thời trang.</p>
      </div>
      <button @click="openCreateModal" class="btn btn-primary">➕ Thêm danh mục mới</button>
    </div>

    <!-- Categories List Table -->
    <div class="card table-card">
      <div v-if="loading" class="loader">Đang tải danh mục...</div>
      <div v-else class="table-wrapper">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Hình ảnh</th>
              <th>Tên Danh mục</th>
              <th>Mô tả</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="categories.length === 0">
              <td colspan="4" class="text-center text-gray">Chưa có danh mục nào được tạo.</td>
            </tr>
            <tr v-else v-for="cat in categories" :key="cat.id">
              <td>
                <div class="cat-thumb">
                  <img :src="cat.imageUrl || 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=100'" alt="Cat Image">
                </div>
              </td>
              <td><strong>{{ cat.name }}</strong></td>
              <td>{{ cat.description || 'Chưa có mô tả' }}</td>
              <td>
                <div class="actions-group">
                  <button @click="openEditModal(cat)" class="btn-action edit-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    Sửa
                  </button>
                  <button @click="handleDeleteCategory(cat.id)" class="btn-action delete-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"></path><path d="M10 11v6"></path><path d="M14 11v6"></path><path d="M9 6V4h6v2"></path></svg>
                    Xoá
                  </button>
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
          <h2>{{ isEditMode ? 'Cập nhật Danh mục' : 'Thêm Danh mục mới' }}</h2>
          <button @click="showModal = false" class="close-modal">&times;</button>
        </div>

        <form @submit.prevent="saveCategory" class="modal-form">
          <div class="form-group">
            <label for="m-name">Tên danh mục *</label>
            <input 
              type="text" 
              id="m-name" 
              v-model="catForm.name" 
              required 
              placeholder="ví dụ: Áo thun, Quần Jean..."
              class="form-control"
            >
          </div>

          <div class="form-group">
            <label for="m-desc">Mô tả chi tiết</label>
            <textarea 
              id="m-desc" 
              v-model="catForm.description" 
              rows="3" 
              placeholder="Nhập vài dòng mô tả ngắn..."
              class="form-control"
            ></textarea>
          </div>

          <div class="form-group">
            <label>Hình ảnh danh mục</label>
            <div class="image-upload-wrapper">
              <div class="img-preview" v-if="catForm.imageUrl">
                <img :src="catForm.imageUrl" alt="Preview">
                <button type="button" @click="catForm.imageUrl = ''" class="remove-preview-btn">&times;</button>
              </div>
              <div class="upload-trigger" v-else>
                <input type="file" @change="uploadImage" accept="image/*" class="file-input-hide" id="img-upload">
                <label for="img-upload" class="upload-label">
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                  <span>Tải ảnh lên</span>
                </label>
              </div>
              <p v-if="uploading" class="uploading-text">Đang tải ảnh lên...</p>
            </div>
          </div>

          <div class="modal-actions">
            <button type="button" @click="showModal = false" class="btn btn-outline">Huỷ bỏ</button>
            <button type="submit" class="btn btn-primary" :disabled="uploading">
              {{ isEditMode ? 'Cập nhật' : 'Thêm mới' }}
            </button>
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
  name: 'CategoryManagementView',
  setup() {
    const categories = ref([]);
    const loading = ref(true);
    const showModal = ref(false);
    const isEditMode = ref(false);
    const uploading = ref(false);
    const editId = ref(null);

    const catForm = reactive({
      name: '',
      description: '',
      imageUrl: ''
    });

    const fetchCategories = async () => {
      loading.value = true;
      try {
        const response = await axios.get('/api/categories');
        categories.value = response.data;
      } catch (err) {
        console.error('Lỗi tải danh mục:', err);
      } finally {
        loading.value = false;
      }
    };

    const openCreateModal = () => {
      isEditMode.value = false;
      editId.value = null;
      catForm.name = '';
      catForm.description = '';
      catForm.imageUrl = '';
      showModal.value = true;
    };

    const openEditModal = (cat) => {
      isEditMode.value = true;
      editId.value = cat.id;
      catForm.name = cat.name;
      catForm.description = cat.description || '';
      catForm.imageUrl = cat.imageUrl || '';
      showModal.value = true;
    };

    const uploadImage = async (event) => {
      const file = event.target.files[0];
      if (!file) return;

      const formData = new FormData();
      formData.append('file', file);
      
      uploading.value = true;
      try {
        const response = await axios.post('/api/admin/upload', formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        });
        catForm.imageUrl = response.data.url;
      } catch (err) {
        console.error('Lỗi upload ảnh:', err);
        alert('Tải ảnh lên thất bại!');
      } finally {
        uploading.value = false;
      }
    };

    const saveCategory = async () => {
      try {
        if (isEditMode.value) {
          await axios.put(`/api/admin/categories/${editId.value}`, { ...catForm });
        } else {
          await axios.post('/api/admin/categories', { ...catForm });
        }
        showModal.value = false;
        fetchCategories();
      } catch (err) {
        console.error('Lỗi lưu danh mục:', err);
        alert(err.response?.data?.message || 'Không thể lưu danh mục.');
      }
    };

    const handleDeleteCategory = async (id) => {
      if (confirm('Bạn có chắc chắn muốn xoá danh mục này? Các sản phẩm thuộc danh mục sẽ bị huỷ liên kết.')) {
        try {
          await axios.delete(`/api/admin/categories/${id}`);
          fetchCategories();
        } catch (err) {
          console.error(err);
          alert('Không thể xoá danh mục.');
        }
      }
    };

    onMounted(() => {
      fetchCategories();
    });

    return {
      categories,
      loading,
      showModal,
      isEditMode,
      catForm,
      uploading,
      openCreateModal,
      openEditModal,
      uploadImage,
      saveCategory,
      handleDeleteCategory
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

.cat-thumb {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  border: 1px solid var(--border);
  background-color: var(--gray-light);
}

.cat-thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
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

/* Modal Styling */
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

/* Image Upload section styles */
.image-upload-wrapper {
  border: 2px dashed var(--border);
  border-radius: var(--radius);
  padding: 16px;
  text-align: center;
  background-color: var(--gray-light);
  position: relative;
}

.img-preview {
  position: relative;
  max-height: 150px;
  overflow: hidden;
  border-radius: var(--radius-sm);
}

.img-preview img {
  max-width: 100%;
  max-height: 150px;
  object-fit: contain;
}

.remove-preview-btn {
  position: absolute;
  top: 5px;
  right: 5px;
  background: rgba(0,0,0,0.7);
  color: var(--white);
  border: none;
  border-radius: 50%;
  width: 25px;
  height: 25px;
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
  display: block;
  cursor: pointer;
  font-weight: 600;
  color: var(--primary);
  padding: 20px;
}

.uploading-text {
  font-size: 12px;
  color: var(--primary);
  margin-top: 8px;
}

.text-center { text-align: center; }
.text-gray { color: var(--gray); }

.loader {
  text-align: center;
  padding: 40px;
}
</style>

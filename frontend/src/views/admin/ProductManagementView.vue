<template>
  <div class="product-mgmt-page fade-in">
    <div class="page-header-row">
      <div>
        <h1>Quản lý Sản phẩm</h1>
        <p>CRUD sản phẩm chính, quản lý ảnh phụ và lập biến thể kích thước/màu sắc.</p>
      </div>
      <button @click="openCreateModal" class="btn btn-primary">➕ Thêm sản phẩm mới</button>
    </div>

    <!-- Product list search bar -->
    <div class="card search-card">
      <div class="search-inputs">
        <input 
          type="text" 
          v-model="searchKeyword" 
          placeholder="Tìm theo tên sản phẩm hoặc thương hiệu..."
          class="form-control"
          @input="fetchProducts"
        >
        <select v-model="selectedCategory" class="form-control" @change="fetchProducts">
          <option :value="null">Tất cả danh mục</option>
          <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
        </select>
      </div>
    </div>

    <!-- Products Table -->
    <div class="card table-card">
      <div v-if="loading" class="loader">Đang tải danh sách sản phẩm...</div>
      <div v-else class="table-wrapper">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Hình ảnh</th>
              <th>Tên sản phẩm</th>
              <th>Thương hiệu</th>
              <th>Danh mục</th>
              <th>Giá bán</th>
              <th>Trạng thái</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="products.length === 0">
              <td colspan="7" class="text-center text-gray">Không tìm thấy sản phẩm nào.</td>
            </tr>
            <tr v-else v-for="prod in products" :key="prod.id">
              <td>
                <div class="prod-thumb">
                  <img :src="prod.imageUrl" alt="Product thumbnail">
                </div>
              </td>
              <td><strong>{{ prod.name }}</strong></td>
              <td>{{ prod.brand }}</td>
              <td>{{ prod.categoryName || 'Không có' }}</td>
              <td class="gold-bold">{{ formatCurrency(prod.price) }}</td>
              <td>
                <span class="badge" :class="prod.status === 'ACTIVE' ? 'badge-success' : 'badge-danger'">
                  {{ prod.status === 'ACTIVE' ? 'Đang bán' : 'Ngừng bán' }}
                </span>
              </td>
              <td>
                <div class="actions-group">
                  <button @click="openEditModal(prod)" class="btn-action edit-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    Sửa
                  </button>
                  <button @click="handleDeleteProduct(prod.id)" class="btn-action delete-btn">
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

    <!-- Edit/Create Product Modal (Full-featured layout) -->
    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content-lg card">
        <div class="modal-header">
          <h2>{{ isEditMode ? 'Cập nhật Sản phẩm' : 'Thêm Sản phẩm mới' }}</h2>
          <button @click="showModal = false" class="close-modal">&times;</button>
        </div>

        <form @submit.prevent="saveProduct" class="modal-form">
          <!-- Two-column main inputs -->
          <div class="form-columns">
            <div class="form-col">
              <div class="form-group">
                <label for="p-name">Tên sản phẩm *</label>
                <input type="text" id="p-name" v-model="prodForm.name" required class="form-control">
              </div>

              <div class="form-group">
                <label for="p-brand">Thương hiệu</label>
                <input type="text" id="p-brand" v-model="prodForm.brand" class="form-control">
              </div>

              <div class="form-group">
                <label for="p-category">Danh mục *</label>
                <select id="p-category" v-model="prodForm.categoryId" required class="form-control">
                  <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
                </select>
              </div>

              <div class="form-group">
                <label for="p-desc">Mô tả sản phẩm</label>
                <textarea id="p-desc" v-model="prodForm.description" rows="4" class="form-control"></textarea>
              </div>
            </div>

            <div class="form-col">
              <div class="form-group">
                <label for="p-price">Giá bán (VND) *</label>
                <input type="number" id="p-price" v-model.number="prodForm.price" required class="form-control">
              </div>

              <div class="form-group">
                <label for="p-origPrice">Giá gốc (VND)</label>
                <input type="number" id="p-origPrice" v-model.number="prodForm.originalPrice" class="form-control">
              </div>

              <div class="form-group">
                <label for="p-status">Trạng thái</label>
                <select id="p-status" v-model="prodForm.status" class="form-control">
                  <option value="ACTIVE">ACTIVE (Đang bán)</option>
                  <option value="INACTIVE">INACTIVE (Ngừng bán)</option>
                </select>
              </div>

              <div class="form-group">
                <label>Ảnh đại diện sản phẩm *</label>
                <div class="image-upload-wrapper">
                  <div class="img-preview" v-if="prodForm.imageUrl">
                    <img :src="prodForm.imageUrl" alt="Preview">
                    <button type="button" @click="prodForm.imageUrl = ''" class="remove-preview-btn">&times;</button>
                  </div>
                  <div class="upload-trigger" v-else>
                    <input type="file" @change="uploadMainImage" accept="image/*" class="file-input-hide" id="main-img-upload">
                    <label for="main-img-upload" class="upload-label">
                      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                      <span>Tải ảnh chính</span>
                    </label>
                  </div>
                  <p v-if="mainUploading" class="uploading-text">Đang tải ảnh...</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Secondary Images & Variants Config (Only visible in Edit Mode to keep flow simple) -->
          <div v-if="isEditMode" class="advanced-configs">
            <div class="details-divider"></div>
            
            <!-- Secondary Images Config -->
            <div class="config-widget">
              <h3>Ảnh phụ sản phẩm</h3>
              <div class="sec-images-row">
                <div class="sec-img-item" v-for="img in secondaryImages" :key="img.id">
                  <img :src="img.imageUrl" alt="Sec image">
                </div>
                <div class="sec-img-upload-btn">
                  <input type="file" @change="uploadSecondaryImage" accept="image/*" class="file-input-hide" id="sec-img-upload">
                  <label for="sec-img-upload" class="sec-upload-label">+</label>
                </div>
              </div>
              <button type="button" @click="clearSecondaryImages" class="btn btn-outline btn-sm clear-sec-btn">Xoá toàn bộ ảnh phụ</button>
            </div>

            <div class="details-divider"></div>

            <!-- Variants Table Manager -->
            <div class="config-widget">
              <div class="config-header">
                <h3>Quản lý Biến thể (Sizes & Colors)</h3>
                <button type="button" @click="addVariantRow" class="btn btn-outline btn-sm">➕ Thêm dòng biến thể</button>
              </div>

              <table class="variant-mgmt-table">
                <thead>
                  <tr>
                    <th>Size (S, M, L, XL...)</th>
                    <th>Màu sắc</th>
                    <th>Số lượng tồn kho</th>
                    <th>Mã SKU</th>
                    <th>Xóa</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(v, index) in prodForm.variants" :key="index">
                    <td><input type="text" v-model="v.size" required class="form-control tab-input"></td>
                    <td><input type="text" v-model="v.color" required class="form-control tab-input"></td>
                    <td><input type="number" v-model.number="v.stock" required class="form-control tab-input"></td>
                    <td><input type="text" v-model="v.sku" required class="form-control tab-input"></td>
                    <td><button type="button" @click="removeVariantRow(index)" class="del-var-row-btn">&times;</button></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <div class="modal-actions">
            <button type="button" @click="showModal = false" class="btn btn-outline">Huỷ bỏ</button>
            <button type="submit" class="btn btn-primary" :disabled="mainUploading || secUploading">
              Lưu sản phẩm
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
  name: 'ProductManagementView',
  setup() {
    const products = ref([]);
    const categories = ref([]);
    const secondaryImages = ref([]);
    const loading = ref(true);
    
    const searchKeyword = ref('');
    const selectedCategory = ref(null);

    const showModal = ref(false);
    const isEditMode = ref(false);
    const mainUploading = ref(false);
    const secUploading = ref(false);
    const editId = ref(null);

    const prodForm = reactive({
      name: '',
      brand: '',
      categoryId: '',
      description: '',
      price: '',
      originalPrice: '',
      imageUrl: '',
      status: 'ACTIVE',
      variants: []
    });

    const fetchCategories = async () => {
      try {
        const response = await axios.get('/api/categories');
        categories.value = response.data;
        if (categories.value.length > 0) {
          prodForm.categoryId = categories.value[0].id;
        }
      } catch (err) {
        console.error(err);
      }
    };

    const fetchProducts = async () => {
      loading.value = true;
      try {
        const params = { status: 'ALL' };
        if (searchKeyword.value) params.keyword = searchKeyword.value;
        if (selectedCategory.value) params.categoryId = selectedCategory.value;

        const response = await axios.get('/api/products', { params });
        products.value = response.data;
      } catch (err) {
        console.error('Lỗi tải sản phẩm:', err);
      } finally {
        loading.value = false;
      }
    };

    const fetchSecondaryData = async (id) => {
      try {
        const res = await axios.get(`/api/products/${id}`);
        secondaryImages.value = res.data.images || [];
        prodForm.variants = res.data.variants || [];
      } catch (err) {
        console.error(err);
      }
    };

    const openCreateModal = () => {
      isEditMode.value = false;
      editId.value = null;
      prodForm.name = '';
      prodForm.brand = '';
      prodForm.description = '';
      prodForm.price = '';
      prodForm.originalPrice = '';
      prodForm.imageUrl = '';
      prodForm.status = 'ACTIVE';
      prodForm.variants = [];
      if (categories.value.length > 0) {
        prodForm.categoryId = categories.value[0].id;
      }
      showModal.value = true;
    };

    const openEditModal = async (prod) => {
      isEditMode.value = true;
      editId.value = prod.id;
      prodForm.name = prod.name;
      prodForm.brand = prod.brand || '';
      prodForm.categoryId = prod.categoryId;
      prodForm.description = prod.description || '';
      prodForm.price = prod.price;
      prodForm.originalPrice = prod.originalPrice || '';
      prodForm.imageUrl = prod.imageUrl;
      prodForm.status = prod.status;
      prodForm.variants = [];
      
      showModal.value = true;
      await fetchSecondaryData(prod.id);
    };

    const uploadMainImage = async (event) => {
      const file = event.target.files[0];
      if (!file) return;

      const formData = new FormData();
      formData.append('file', file);
      
      mainUploading.value = true;
      try {
        const response = await axios.post('/api/admin/upload', formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        });
        prodForm.imageUrl = response.data.url;
      } catch (err) {
        console.error(err);
        alert('Tải ảnh lên thất bại!');
      } finally {
        mainUploading.value = false;
      }
    };

    const uploadSecondaryImage = async (event) => {
      const file = event.target.files[0];
      if (!file) return;

      const formData = new FormData();
      formData.append('file', file);

      secUploading.value = true;
      try {
        const response = await axios.post('/api/admin/upload', formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        });
        // Create secondary image relationship on server
        await axios.post(`/api/admin/products/${editId.value}/images?imageUrl=${response.data.url}`);
        await fetchSecondaryData(editId.value);
      } catch (err) {
        console.error(err);
      } finally {
        secUploading.value = false;
      }
    };

    const clearSecondaryImages = async () => {
      if (confirm('Xoá tất cả ảnh phụ của sản phẩm này?')) {
        try {
          await axios.delete(`/api/admin/products/${editId.value}/images`);
          secondaryImages.value = [];
        } catch (err) {
          console.error(err);
        }
      }
    };

    const addVariantRow = () => {
      prodForm.variants.push({
        size: 'M',
        color: 'Trắng',
        stock: 50,
        sku: 'SKU-' + Date.now().toString().substring(8)
      });
    };

    const removeVariantRow = (idx) => {
      prodForm.variants.splice(idx, 1);
    };

    const saveProduct = async () => {
      try {
        let savedProd;
        if (isEditMode.value) {
          const res = await axios.put(`/api/admin/products/${editId.value}`, {
            name: prodForm.name,
            brand: prodForm.brand,
            categoryId: prodForm.categoryId,
            description: prodForm.description,
            price: prodForm.price,
            originalPrice: prodForm.originalPrice,
            imageUrl: prodForm.imageUrl,
            status: prodForm.status
          });
          savedProd = res.data;

          // Save variants
          await axios.post(`/api/admin/products/${editId.value}/variants`, prodForm.variants);
        } else {
          const res = await axios.post('/api/admin/products', {
            name: prodForm.name,
            brand: prodForm.brand,
            categoryId: prodForm.categoryId,
            description: prodForm.description,
            price: prodForm.price,
            originalPrice: prodForm.originalPrice,
            imageUrl: prodForm.imageUrl,
            status: prodForm.status
          });
          savedProd = res.data;
        }

        showModal.value = false;
        fetchProducts();
      } catch (err) {
        console.error(err);
        alert(err.response?.data?.message || 'Không thể lưu sản phẩm.');
      }
    };

    const handleDeleteProduct = async (id) => {
      if (confirm('Bạn có chắc chắn muốn xoá hoàn toàn sản phẩm này?')) {
        try {
          await axios.delete(`/api/admin/products/${id}`);
          fetchProducts();
        } catch (err) {
          console.error(err);
        }
      }
    };

    const formatCurrency = (val) => {
      if (!val) return '0đ';
      return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
    };

    onMounted(() => {
      fetchCategories();
      fetchProducts();
    });

    return {
      products,
      categories,
      secondaryImages,
      loading,
      searchKeyword,
      selectedCategory,
      showModal,
      isEditMode,
      prodForm,
      mainUploading,
      secUploading,
      openCreateModal,
      openEditModal,
      uploadMainImage,
      uploadSecondaryImage,
      clearSecondaryImages,
      addVariantRow,
      removeVariantRow,
      saveProduct,
      handleDeleteProduct,
      formatCurrency,
      fetchProducts
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

.search-card {
  margin-bottom: 30px;
}

.search-inputs {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
}

.prod-thumb {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  border: 1px solid var(--border);
  background-color: var(--gray-light);
}

.prod-thumb img {
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

/* Modal Styling - Extra Large size for products config */
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

.modal-content-lg {
  width: 900px;
  max-height: 90vh;
  overflow-y: auto;
  padding: 40px;
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

.form-columns {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
}

.advanced-configs {
  margin-top: 30px;
}

.details-divider {
  height: 1px;
  background: var(--border);
  margin: 24px 0;
}

.config-widget h3 {
  font-size: 16px;
  margin-bottom: 16px;
  color: var(--primary);
}

.config-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.sec-images-row {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 12px;
}

.sec-img-item {
  width: 80px;
  height: 80px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  border: 1px solid var(--border);
}

.sec-img-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.sec-img-upload-btn {
  width: 80px;
  height: 80px;
  border: 2px dashed var(--border);
  border-radius: var(--radius-sm);
}

.sec-upload-label {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  font-size: 24px;
  color: var(--gray);
  cursor: pointer;
}

.clear-sec-btn {
  margin-top: 8px;
}

/* Variant management table styling */
.variant-mgmt-table {
  width: 100%;
  border-collapse: collapse;
}

.variant-mgmt-table th, .variant-mgmt-table td {
  padding: 10px;
  border: 1px solid var(--border);
}

.variant-mgmt-table th {
  background: var(--gray-light);
  font-size: 13px;
  text-align: left;
}

.tab-input {
  padding: 6px 12px;
  font-size: 13px;
  border-radius: var(--radius-sm);
}

.del-var-row-btn {
  background: transparent;
  border: none;
  color: #e74c3c;
  font-size: 20px;
  cursor: pointer;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 30px;
}

/* Image Upload styles */
.image-upload-wrapper {
  border: 2px dashed var(--border);
  border-radius: var(--radius);
  padding: 16px;
  text-align: center;
  background-color: var(--gray-light);
}

.img-preview {
  position: relative;
  max-height: 120px;
  overflow: hidden;
}

.img-preview img {
  max-width: 100%;
  max-height: 120px;
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
}

.file-input-hide { display: none; }
.upload-label {
  display: block;
  cursor: pointer;
  font-weight: 600;
  color: var(--primary);
  padding: 16px;
}

.uploading-text {
  font-size: 12px;
  color: var(--primary);
}

.text-center { text-align: center; }
.text-gray { color: var(--gray); }

.loader {
  text-align: center;
  padding: 60px;
}
</style>

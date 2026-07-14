<template>
  <div class="shop-page fade-in">
    <div class="container shop-container">
      <!-- Sidebar Filters -->
      <aside class="shop-sidebar">
        <!-- Search Box -->
        <div class="sidebar-widget">
          <h3>Tìm kiếm</h3>
          <div class="search-box">
            <input 
              type="text" 
              v-model="filters.keyword" 
              placeholder="Nhập tên, thương hiệu..." 
              @input="handleFilterChange"
              class="form-control"
            >
          </div>
        </div>

        <!-- Categories Widget -->
        <div class="sidebar-widget">
          <h3>Danh mục sản phẩm</h3>
          <ul class="filter-list">
            <li>
              <button 
                :class="{ active: filters.categoryId === null }" 
                @click="selectCategory(null)"
              >
                Tất cả danh mục
              </button>
            </li>
            <li v-for="cat in categories" :key="cat.id">
              <button 
                :class="{ active: filters.categoryId === cat.id }" 
                @click="selectCategory(cat.id)"
              >
                {{ cat.name }}
              </button>
            </li>
          </ul>
        </div>

        <!-- Brands Widget -->
        <div class="sidebar-widget">
          <h3>Thương hiệu</h3>
          <ul class="filter-list">
            <li>
              <button 
                :class="{ active: filters.brand === null }" 
                @click="selectBrand(null)"
              >
                Tất cả thương hiệu
              </button>
            </li>
            <li v-for="brand in brands" :key="brand">
              <button 
                :class="{ active: filters.brand === brand }" 
                @click="selectBrand(brand)"
              >
                {{ brand }}
              </button>
            </li>
          </ul>
        </div>

        <!-- Price Range Widget -->
        <div class="sidebar-widget">
          <h3>Khoảng giá (VND)</h3>
          <div class="price-inputs">
            <input 
              type="number" 
              v-model.number="filters.minPrice" 
              placeholder="Từ" 
              @change="handleFilterChange"
              class="form-control price-input"
            >
            <span class="price-separator">-</span>
            <input 
              type="number" 
              v-model.number="filters.maxPrice" 
              placeholder="Đến" 
              @change="handleFilterChange"
              class="form-control price-input"
            >
          </div>
          <button @click="resetPriceFilter" class="btn btn-outline btn-sm reset-price-btn">Xoá lọc giá</button>
        </div>
      </aside>

      <!-- Products Content -->
      <main class="shop-content">
        <div class="content-header">
          <p class="results-count">Tìm thấy <strong>{{ products.length }}</strong> sản phẩm</p>
          <button @click="resetAllFilters" class="btn btn-outline btn-sm">Xoá tất cả bộ lọc</button>
        </div>

        <div v-if="loading" class="loader">Đang tải sản phẩm...</div>
        <div v-else-if="products.length === 0" class="no-products">
          <p>Không tìm thấy sản phẩm nào phù hợp với bộ lọc của bạn.</p>
        </div>
        <div v-else class="products-grid">
          <!-- Product Card -->
          <div class="product-card" v-for="prod in products" :key="prod.id">
            <div class="prod-image-wrapper">
              <span v-if="prod.originalPrice && prod.originalPrice > prod.price" class="sale-badge">SALE</span>
              <img 
                :src="prod.imageUrl || 'https://images.pexels.com/photos/5886041/pexels-photo-5886041.jpeg?auto=compress&cs=tinysrgb&w=400'" 
                :alt="prod.name"
                @error="$event.target.src='https://images.pexels.com/photos/5886041/pexels-photo-5886041.jpeg?auto=compress&cs=tinysrgb&w=400'"
              >
              <div class="prod-overlay">
                <router-link :to="'/products/' + prod.id" class="btn btn-primary btn-sm">Xem chi tiết</router-link>
              </div>
            </div>
            <div class="prod-info">
              <span class="prod-brand">{{ prod.brand }}</span>
              <router-link :to="'/products/' + prod.id"><h3 class="prod-name">{{ prod.name }}</h3></router-link>
              <div class="prod-rating">
                <span class="star-rating">★</span> {{ prod.rating ? prod.rating.toFixed(1) : '5.0' }}
              </div>
              <div class="prod-price-row">
                <span class="price">{{ formatCurrency(prod.price) }}</span>
                <span v-if="prod.originalPrice" class="original-price">{{ formatCurrency(prod.originalPrice) }}</span>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';

export default {
  name: 'ShopView',
  setup() {
    const route = useRoute();
    const router = useRouter();

    const categories = ref([]);
    const brands = ref([]);
    const products = ref([]);
    const loading = ref(true);

    const filters = reactive({
      keyword: '',
      categoryId: null,
      brand: null,
      minPrice: null,
      maxPrice: null
    });

    const fetchCategoriesAndBrands = async () => {
      try {
        const categoriesRes = await axios.get('/api/categories');
        categories.value = categoriesRes.data;

        const brandsRes = await axios.get('/api/products/brands');
        brands.value = brandsRes.data;
      } catch (err) {
        console.error('Lỗi tải danh mục / thương hiệu:', err);
      }
    };

    const fetchProducts = async () => {
      loading.value = true;
      try {
        const params = {};
        if (filters.keyword) params.keyword = filters.keyword;
        if (filters.categoryId) params.categoryId = filters.categoryId;
        if (filters.brand) params.brand = filters.brand;
        if (filters.minPrice !== null && filters.minPrice !== '') params.minPrice = filters.minPrice;
        if (filters.maxPrice !== null && filters.maxPrice !== '') params.maxPrice = filters.maxPrice;

        const res = await axios.get('/api/products', { params });
        products.value = res.data;
      } catch (err) {
        console.error('Lỗi tải sản phẩm:', err);
      } finally {
        loading.value = false;
      }
    };

    const parseQuery = () => {
      if (route.query.categoryId) {
        filters.categoryId = parseInt(route.query.categoryId);
      } else {
        filters.categoryId = null;
      }
      if (route.query.keyword) {
        filters.keyword = route.query.keyword;
      }
      fetchProducts();
    };

    const handleFilterChange = () => {
      fetchProducts();
    };

    const selectCategory = (id) => {
      filters.categoryId = id;
      // Sync route queries
      router.replace({ path: '/shop', query: { ...route.query, categoryId: id || undefined } });
    };

    const selectBrand = (brand) => {
      filters.brand = brand;
      fetchProducts();
    };

    const resetPriceFilter = () => {
      filters.minPrice = null;
      filters.maxPrice = null;
      fetchProducts();
    };

    const resetAllFilters = () => {
      filters.keyword = '';
      filters.categoryId = null;
      filters.brand = null;
      filters.minPrice = null;
      filters.maxPrice = null;
      router.replace({ path: '/shop' });
    };

    const formatCurrency = (val) => {
      if (!val) return '0đ';
      return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
    };

    onMounted(() => {
      fetchCategoriesAndBrands();
      parseQuery();
    });

    watch(() => route.query, () => {
      parseQuery();
    });

    return {
      categories,
      brands,
      products,
      loading,
      filters,
      selectCategory,
      selectBrand,
      handleFilterChange,
      resetPriceFilter,
      resetAllFilters,
      formatCurrency
    };
  }
};
</script>

<style scoped>
.shop-page {
  padding: 60px 0;
}

.shop-container {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 40px;
  align-items: start;
}

/* Sidebar Widgets */
.shop-sidebar {
  background: var(--white);
  border-radius: var(--radius);
  padding: 30px;
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(197, 168, 128, 0.08);
}

.sidebar-widget {
  margin-bottom: 35px;
}

.sidebar-widget:last-child {
  margin-bottom: 0;
}

.sidebar-widget h3 {
  font-size: 18px;
  margin-bottom: 20px;
  border-left: 3px solid var(--primary);
  padding-left: 10px;
  font-family: var(--font-heading);
}

.filter-list button {
  display: block;
  width: 100%;
  text-align: left;
  background: transparent;
  border: none;
  padding: 8px 12px;
  font-size: 14px;
  font-weight: 500;
  color: var(--gray-dark);
  border-radius: var(--radius-sm);
}

.filter-list button:hover {
  background: var(--gray-light);
  color: var(--primary);
}

.filter-list button.active {
  background: #fdfbf7;
  color: var(--primary);
  font-weight: 700;
}

.price-inputs {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

.price-input {
  width: 100%;
  padding: 8px;
  font-size: 13px;
  text-align: center;
}

.price-separator {
  color: var(--gray);
}

.reset-price-btn {
  width: 100%;
  padding: 8px;
  font-size: 12px;
}

/* Products Content area */
.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  background: var(--white);
  padding: 16px 24px;
  border-radius: var(--radius);
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(197, 168, 128, 0.08);
}

.results-count {
  font-size: 15px;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

/* Product Card reused styles */
.product-card {
  background: var(--white);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  transition: var(--transition);
  position: relative;
  display: flex;
  flex-direction: column;
  border: 1px solid rgba(197, 168, 128, 0.08);
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow);
}

.prod-image-wrapper {
  height: 260px;
  position: relative;
  overflow: hidden;
  background-color: var(--gray-light);
}

.prod-image-wrapper img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: var(--transition);
}

.product-card:hover .prod-image-wrapper img {
  transform: scale(1.05);
}

.sale-badge {
  position: absolute;
  top: 15px;
  left: 15px;
  background: #e74c3c;
  color: var(--white);
  padding: 4px 10px;
  font-size: 11px;
  font-weight: 700;
  border-radius: 4px;
  z-index: 5;
}

.prod-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  padding: 20px;
  background: linear-gradient(to top, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0) 100%);
  display: flex;
  justify-content: center;
  opacity: 0;
  transition: var(--transition);
  transform: translateY(20px);
}

.product-card:hover .prod-overlay {
  opacity: 1;
  transform: translateY(0);
}

.prod-info {
  padding: 20px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.prod-brand {
  font-size: 12px;
  font-weight: 600;
  color: var(--primary);
  text-transform: uppercase;
  margin-bottom: 6px;
}

.prod-name {
  font-size: 15px;
  font-weight: 600;
  color: var(--dark-light);
  margin-bottom: 8px;
  height: 44px;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.prod-rating {
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 12px;
}

.star-rating {
  color: #f39c12;
}

.prod-price-row {
  margin-top: auto;
  display: flex;
  align-items: center;
  gap: 12px;
}

.price {
  font-size: 16px;
  font-weight: 700;
  color: var(--dark);
}

.original-price {
  font-size: 13px;
  color: var(--gray);
  text-decoration: line-through;
}

.no-products {
  text-align: center;
  padding: 80px 0;
  font-size: 18px;
  color: var(--gray);
  background: var(--white);
  border-radius: var(--radius);
  border: 1px solid rgba(197, 168, 128, 0.08);
}

.loader {
  text-align: center;
  padding: 80px 0;
  font-size: 18px;
  color: var(--gray);
}

@media (max-width: 992px) {
  .shop-container {
    grid-template-columns: 1fr;
  }
  .products-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 576px) {
  .products-grid {
    grid-template-columns: 1fr;
  }
}
</style>

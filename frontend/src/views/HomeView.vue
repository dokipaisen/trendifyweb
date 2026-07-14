<template>
  <div class="home-container">
    <!-- Hero Slider Section -->
    <section class="hero-slider" v-if="banners.length > 0">
      <div 
        class="slide-item" 
        v-for="(banner, index) in banners" 
        :key="banner.id"
        v-show="currentSlide === index"
        :style="{ backgroundImage: 'linear-gradient(to right, rgba(0,0,0,0.6), rgba(0,0,0,0.1)), url(' + banner.imageUrl + ')' }"
      >
        <div class="container slide-content">
          <h1 class="slide-title fade-in">{{ banner.title }}</h1>
          <p class="slide-subtitle fade-in">Bộ sưu tập thời trang mới nhất đón đầu xu hướng thời trang năm 2026.</p>
          <router-link :to="banner.linkUrl || '/shop'" class="btn btn-primary btn-lg fade-in">Mua Ngay</router-link>
        </div>
      </div>
      
      <!-- Slider Arrows -->
      <button @click="prevSlide" class="slide-arrow prev-arrow">&#10094;</button>
      <button @click="nextSlide" class="slide-arrow next-arrow">&#10095;</button>
    </section>

    <!-- Categories Section -->
    <section class="section categories-section">
      <div class="container">
        <h2 class="section-title">Danh mục thời trang</h2>
        <div class="categories-grid">
          <router-link 
            :to="'/shop?categoryId=' + cat.id" 
            class="category-card" 
            v-for="cat in categories" 
            :key="cat.id"
          >
            <div class="cat-image-wrapper">
              <img 
                :src="cat.imageUrl || 'https://images.pexels.com/photos/5886041/pexels-photo-5886041.jpeg?auto=compress&cs=tinysrgb&w=600'" 
                :alt="cat.name"
                @error="$event.target.src='https://images.pexels.com/photos/5886041/pexels-photo-5886041.jpeg?auto=compress&cs=tinysrgb&w=600'"
              >
            </div>
            <div class="cat-info">
              <h3>{{ cat.name }}</h3>
              <p>{{ cat.description }}</p>
            </div>
          </router-link>
        </div>
      </div>
    </section>

    <!-- Featured Products Section -->
    <section class="section featured-section">
      <div class="container">
        <h2 class="section-title">Sản phẩm nổi bật</h2>
        <div v-if="loading" class="loader">Đang tải sản phẩm...</div>
        <div v-else class="grid-4">
          <!-- Product Card Component -->
          <div class="product-card" v-for="prod in featuredProducts" :key="prod.id">
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
        <div class="shop-more-container">
          <router-link to="/shop" class="btn btn-dark">Xem tất cả sản phẩm</router-link>
        </div>
      </div>
    </section>

    <!-- Features Banner (Aesthetic values) -->
    <section class="features-bar">
      <div class="container features-grid">
        <div class="feature-item">
          <span class="feature-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feature-svg"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
          </span>
          <h3>Miễn Phí Vận Chuyển</h3>
          <p>Cho mọi đơn hàng trị giá từ 500k trở lên</p>
        </div>
        <div class="feature-item">
          <span class="feature-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feature-svg"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
          </span>
          <h3>Thanh Toán An Toàn</h3>
          <p>Cam kết bảo mật giao dịch tuyệt đối</p>
        </div>
        <div class="feature-item">
          <span class="feature-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feature-svg"><polyline points="23 4 23 10 17 10"></polyline><polyline points="1 20 1 14 7 14"></polyline><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
          </span>
          <h3>Đổi Trả Dễ Dàng</h3>
          <p>Hỗ trợ đổi trả miễn phí trong vòng 7 ngày</p>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted } from 'vue';
import axios from 'axios';

export default {
  name: 'HomeView',
  setup() {
    const banners = ref([]);
    const categories = ref([]);
    const featuredProducts = ref([]);
    const loading = ref(true);
    
    const currentSlide = ref(0);
    let slideTimer = null;

    const fetchHomeData = async () => {
      try {
        const bannersRes = await axios.get('/api/banners');
        banners.value = bannersRes.data;

        const categoriesRes = await axios.get('/api/categories');
        categories.value = categoriesRes.data;

        const featuredRes = await axios.get('/api/products/featured');
        featuredProducts.value = featuredRes.data;
      } catch (err) {
        console.error('Lỗi tải dữ liệu trang chủ:', err);
      } finally {
        loading.value = false;
      }
    };

    const nextSlide = () => {
      currentSlide.value = (currentSlide.value + 1) % banners.value.length;
    };

    const prevSlide = () => {
      currentSlide.value = (currentSlide.value - 1 + banners.value.length) % banners.value.length;
    };

    const startTimer = () => {
      slideTimer = setInterval(nextSlide, 5000);
    };

    const stopTimer = () => {
      if (slideTimer) clearInterval(slideTimer);
    };

    const formatCurrency = (val) => {
      if (!val) return '0đ';
      return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
    };

    onMounted(() => {
      fetchHomeData().then(() => {
        if (banners.value.length > 1) {
          startTimer();
        }
      });
    });

    onUnmounted(() => {
      stopTimer();
    });

    return {
      banners,
      categories,
      featuredProducts,
      loading,
      currentSlide,
      nextSlide,
      prevSlide,
      formatCurrency
    };
  }
};
</script>

<style scoped>
/* Slider Styles */
.hero-slider {
  height: 600px;
  position: relative;
  overflow: hidden;
  background-color: #000;
}

.slide-item {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: center;
  transition: opacity 0.8s ease-in-out;
}

.slide-content {
  color: var(--white);
  max-width: 600px;
}

.slide-title {
  font-family: var(--font-heading);
  font-size: 54px;
  font-weight: 800;
  line-height: 1.2;
  margin-bottom: 20px;
  text-transform: uppercase;
  color: var(--white) !important;
  letter-spacing: 2px;
}

.slide-subtitle {
  font-size: 18px;
  margin-bottom: 35px;
  color: #dddddd;
}

.slide-arrow {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(0, 0, 0, 0.3);
  border: none;
  color: var(--white);
  font-size: 24px;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: var(--transition);
  z-index: 10;
}

.slide-arrow:hover {
  background: var(--primary);
}

.prev-arrow { left: 30px; }
.next-arrow { right: 30px; }

/* Categories Styles */
.categories-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 20px;
}

.category-card {
  background: var(--white);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  transition: var(--transition);
  text-align: center;
}

.category-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow);
}

.cat-image-wrapper {
  height: 180px;
  overflow: hidden;
}

.cat-image-wrapper img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: var(--transition);
}

.category-card:hover .cat-image-wrapper img {
  transform: scale(1.1);
}

.cat-info {
  padding: 16px;
}

.cat-info h3 {
  font-size: 16px;
  margin-bottom: 6px;
}

.cat-info p {
  font-size: 12px;
  color: var(--gray);
  height: 36px;
  overflow: hidden;
}

/* Featured Products Styles */
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
  height: 280px;
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

.shop-more-container {
  text-align: center;
  margin-top: 50px;
}

/* Features Bar */
.features-bar {
  background: var(--dark-gradient);
  color: var(--white);
  padding: 50px 0;
  border-top: 1px solid rgba(255,255,255,0.05);
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 40px;
  text-align: center;
}

.feature-icon {
  font-size: 36px;
  margin-bottom: 16px;
  display: block;
}

.feature-svg {
  color: var(--primary);
}

.feature-item h3 {
  color: var(--primary);
  font-size: 18px;
  margin-bottom: 8px;
}

.feature-item p {
  font-size: 14px;
  color: #bbbbbb;
}

.loader {
  text-align: center;
  padding: 40px;
  font-size: 18px;
  color: var(--gray);
}

@media (max-width: 992px) {
  .categories-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  .features-grid {
    grid-template-columns: 1fr;
    gap: 30px;
  }
}

@media (max-width: 768px) {
  .hero-slider {
    height: 450px;
  }
  .slide-title {
    font-size: 36px;
  }
  .categories-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 480px) {
  .categories-grid {
    grid-template-columns: 1fr;
  }
}
</style>

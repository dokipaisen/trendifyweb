<template>
  <div class="product-detail-page fade-in">
    <div class="container detail-container" v-if="product">
      <!-- Left Column: Images -->
      <div class="detail-gallery">
        <div class="main-image-wrapper">
          <img :src="activeImage" :alt="product.name" @error="$event.target.src='https://images.pexels.com/photos/5886041/pexels-photo-5886041.jpeg?auto=compress&cs=tinysrgb&w=600'">
        </div>
        <div class="thumbnail-list" v-if="allImages.length > 1">
          <div 
            v-for="(img, idx) in allImages" 
            :key="idx"
            class="thumb-item"
            :class="{ active: activeImage === img }"
            @click="activeImage = img"
          >
            <img :src="img" alt="Product thumbnail">
          </div>
        </div>
      </div>

      <!-- Right Column: Info & Variants -->
      <div class="detail-info">
        <span class="detail-brand">{{ product.brand }}</span>
        <h1 class="detail-name">{{ product.name }}</h1>
        
        <div class="detail-rating-row">
          <div class="stars">
            <span class="star-rating">★</span> {{ product.rating ? product.rating.toFixed(1) : '5.0' }}
          </div>
          <span class="rating-count">({{ reviews.length }} đánh giá từ khách hàng)</span>
        </div>

        <div class="detail-price-row">
          <span class="price">{{ formatCurrency(product.price) }}</span>
          <span v-if="product.originalPrice" class="original-price">{{ formatCurrency(product.originalPrice) }}</span>
        </div>

        <p class="detail-description">{{ product.description || 'Chưa có mô tả chi tiết cho sản phẩm này.' }}</p>

        <!-- Variants Selection -->
        <div class="variants-section">
          <!-- Size Selector -->
          <div class="variant-group" v-if="availableSizes.length > 0">
            <label>Kích thước (Size):</label>
            <div class="variant-options">
              <button 
                v-for="sz in availableSizes" 
                :key="sz"
                :class="{ active: selectedSize === sz }"
                @click="selectSize(sz)"
                class="variant-btn"
              >
                {{ sz }}
              </button>
            </div>
          </div>

          <!-- Color Selector -->
          <div class="variant-group" v-if="availableColors.length > 0">
            <label>Màu sắc:</label>
            <div class="variant-options">
              <button 
                v-for="col in availableColors" 
                :key="col"
                :class="{ active: selectedColor === col }"
                @click="selectColor(col)"
                class="variant-btn"
              >
                {{ col }}
              </button>
            </div>
          </div>

          <!-- Selected Variant Info -->
          <div class="stock-info" v-if="selectedVariant">
            <p v-if="selectedVariant.stock > 0">
              Trạng thái: <span class="badge badge-success">Còn hàng</span> (Số lượng còn lại: {{ selectedVariant.stock }} sản phẩm)
            </p>
            <p v-else>
              Trạng thái: <span class="badge badge-danger">Hết hàng</span>
            </p>
            <p class="sku-info">Mã SKU: <code>{{ selectedVariant.sku }}</code></p>
          </div>
          <div class="stock-info" v-else-if="selectedSize || selectedColor">
            <p class="warn-variant">Vui lòng chọn đầy đủ Size và Màu sắc để xem tình trạng kho.</p>
          </div>
        </div>

        <!-- Add to Cart Column -->
        <div class="actions-section" v-if="selectedVariant && selectedVariant.stock > 0">
          <div class="quantity-selector">
            <button @click="decQty" class="qty-btn">-</button>
            <input type="number" v-model.number="quantity" readonly class="qty-input">
            <button @click="incQty" class="qty-btn">+</button>
          </div>
          <button @click="handleAddToCart" class="btn btn-primary btn-lg add-to-cart-btn">
            Thêm vào giỏ hàng
          </button>
        </div>
        <div class="actions-section" v-else-if="selectedVariant && selectedVariant.stock <= 0">
          <button disabled class="btn btn-dark btn-lg add-to-cart-btn">Hết hàng</button>
        </div>
        <div class="actions-section" v-else>
          <button disabled class="btn btn-dark btn-lg add-to-cart-btn">Vui lòng chọn phân loại</button>
        </div>
      </div>
    </div>

    <!-- Reviews Section -->
    <section class="section reviews-section" v-if="product">
      <div class="container">
        <h2 class="section-title">Nhận xét khách hàng</h2>

        <!-- Review Input (Only for logged in) -->
        <div class="review-form-card card" v-if="authStore.isLoggedIn">
          <h3>Viết đánh giá của bạn</h3>
          <form @submit.prevent="submitReview" class="review-form">
            <div class="form-group">
              <label>Điểm đánh giá (1-5 sao):</label>
              <div class="star-selector">
                <span 
                  v-for="star in 5" 
                  :key="star" 
                  @click="newReview.rating = star"
                  class="star-opt"
                  :class="{ active: star <= newReview.rating }"
                >
                  ★
                </span>
              </div>
            </div>
            <div class="form-group">
              <label for="comment">Bình luận của bạn:</label>
              <textarea 
                id="comment" 
                v-model="newReview.comment" 
                rows="4" 
                required 
                placeholder="Chia sẻ cảm nhận của bạn về phom dáng, chất vải..."
                class="form-control"
              ></textarea>
            </div>
            <button type="submit" class="btn btn-primary" :disabled="submittingReview">
              Gửi nhận xét
            </button>
          </form>
        </div>
        <div class="review-login-prompt card" v-else>
          <p>Bạn cần <router-link to="/login">đăng nhập</router-link> để viết đánh giá cho sản phẩm này.</p>
        </div>

        <!-- Reviews List -->
        <div class="reviews-list">
          <div v-if="reviews.length === 0" class="no-reviews">
            <p>Chưa có đánh giá nào cho sản phẩm này. Hãy là người đầu tiên trải nghiệm và chia sẻ!</p>
          </div>
          <div v-else class="review-item card" v-for="rev in reviews" :key="rev.id">
            <div class="review-header">
              <div class="stars">
                <span v-for="s in rev.rating" :key="s" class="star-rating">★</span>
                <span v-for="s in (5 - rev.rating)" :key="s" class="star-empty">★</span>
              </div>
              <span class="review-date">{{ formatDate(rev.createdAt) }}</span>
            </div>
            <p class="review-comment">{{ rev.comment }}</p>
          </div>
        </div>
      </div>
    </section>

    <div v-else-if="loading" class="loader">Đang tải chi tiết sản phẩm...</div>
    <div v-else class="loader">Sản phẩm không tồn tại.</div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { useCartStore } from '../stores/cart';
import axios from 'axios';

export default {
  name: 'ProductDetailView',
  setup() {
    const route = useRoute();
    const authStore = useAuthStore();
    const cartStore = useCartStore();

    const product = ref(null);
    const secondaryImages = ref([]);
    const variants = ref([]);
    const reviews = ref([]);
    const loading = ref(true);
    
    const activeImage = ref('');
    const selectedSize = ref('');
    const selectedColor = ref('');
    const quantity = ref(1);

    const submittingReview = ref(false);
    const newReview = ref({
      rating: 5,
      comment: ''
    });

    const fetchDetail = async () => {
      try {
        const id = route.params.id;
        const res = await axios.get(`/api/products/${id}`);
        product.value = res.data.product;
        secondaryImages.value = res.data.images;
        variants.value = res.data.variants;
        reviews.value = res.data.reviews;

        activeImage.value = product.value.imageUrl;

        // Auto select first variant if available
        if (variants.value.length > 0) {
          selectedSize.value = variants.value[0].size;
          selectedColor.value = variants.value[0].color;
        }
      } catch (err) {
        console.error('Lỗi tải chi tiết sản phẩm:', err);
      } finally {
        loading.value = false;
      }
    };

    const allImages = computed(() => {
      if (!product.value) return [];
      const list = [product.value.imageUrl];
      secondaryImages.value.forEach(img => list.push(img.imageUrl));
      return list;
    });

    const availableSizes = computed(() => {
      const sizes = variants.value.map(v => v.size);
      return [...new Set(sizes)];
    });

    const availableColors = computed(() => {
      const colors = variants.value.map(v => v.color);
      return [...new Set(colors)];
    });

    const selectedVariant = computed(() => {
      if (!selectedSize.value || !selectedColor.value) return null;
      return variants.value.find(v => v.size === selectedSize.value && v.color === selectedColor.value) || null;
    });

    const selectSize = (sz) => {
      selectedSize.value = sz;
      quantity.value = 1;
    };

    const selectColor = (col) => {
      selectedColor.value = col;
      quantity.value = 1;
    };

    const incQty = () => {
      if (selectedVariant.value && quantity.value < selectedVariant.value.stock) {
        quantity.value++;
      }
    };

    const decQty = () => {
      if (quantity.value > 1) {
        quantity.value--;
      }
    };

    const handleAddToCart = async () => {
      if (!selectedVariant.value) return;
      try {
        await cartStore.addToCart(product.value, selectedVariant.value, quantity.value);
      } catch (err) {
        console.error(err);
      }
    };

    const submitReview = async () => {
      submittingReview.value = true;
      try {
        const id = route.params.id;
        await axios.post(`/api/products/${id}/reviews`, newReview.value);
        // Refresh details
        await fetchDetail();
        newReview.value.rating = 5;
        newReview.value.comment = '';
        cartStore.success = 'Gửi nhận xét sản phẩm thành công!';
      } catch (err) {
        console.error(err);
      } finally {
        submittingReview.value = false;
      }
    };

    const formatCurrency = (val) => {
      if (!val) return '0đ';
      return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
    };

    const formatDate = (dateStr) => {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString('vi-VN', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' });
    };

    onMounted(() => {
      fetchDetail();
    });

    return {
      authStore,
      cartStore,
      product,
      secondaryImages,
      variants,
      reviews,
      loading,
      activeImage,
      allImages,
      availableSizes,
      availableColors,
      selectedSize,
      selectedColor,
      selectedVariant,
      quantity,
      newReview,
      submittingReview,
      selectSize,
      selectColor,
      incQty,
      decQty,
      handleAddToCart,
      submitReview,
      formatCurrency,
      formatDate
    };
  }
};
</script>

<style scoped>
.product-detail-page {
  padding: 60px 0;
}

.detail-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 50px;
  align-items: start;
}

/* Gallery styles */
.detail-gallery {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.main-image-wrapper {
  height: 500px;
  border-radius: var(--radius);
  overflow: hidden;
  background: var(--gray-light);
  border: 1px solid var(--border);
}

.main-image-wrapper img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.thumbnail-list {
  display: flex;
  gap: 12px;
  overflow-x: auto;
}

.thumb-item {
  width: 90px;
  height: 90px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  border: 2px solid transparent;
  cursor: pointer;
  background: var(--gray-light);
}

.thumb-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.thumb-item.active {
  border-color: var(--primary);
}

/* Info Column styles */
.detail-info {
  display: flex;
  flex-direction: column;
}

.detail-brand {
  font-size: 14px;
  font-weight: 700;
  color: var(--primary);
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 8px;
}

.detail-name {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 12px;
  line-height: 1.3;
}

.detail-rating-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
  font-weight: 600;
  font-size: 14px;
}

.star-rating {
  color: #f39c12;
}

.rating-count {
  color: var(--gray);
}

.detail-price-row {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.detail-price-row .price {
  font-size: 28px;
  font-weight: 800;
  color: var(--dark);
}

.detail-price-row .original-price {
  font-size: 18px;
  color: var(--gray);
  text-decoration: line-through;
}

.detail-description {
  color: var(--gray-dark);
  font-size: 15px;
  margin-bottom: 30px;
  white-space: pre-line;
}

/* Variants Selection styling */
.variants-section {
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  padding: 24px 0;
  margin-bottom: 30px;
}

.variant-group {
  margin-bottom: 20px;
}

.variant-group label {
  display: block;
  font-size: 14px;
  font-weight: 700;
  color: var(--dark-light);
  margin-bottom: 10px;
}

.variant-options {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.variant-btn {
  padding: 8px 20px;
  font-size: 14px;
  font-weight: 600;
  border-radius: var(--radius-sm);
  background: var(--white);
  border: 1px solid var(--border);
}

.variant-btn:hover {
  border-color: var(--primary);
  color: var(--primary);
}

.variant-btn.active {
  background: var(--primary);
  border-color: var(--primary);
  color: var(--white);
}

.stock-info {
  font-size: 14px;
  font-weight: 600;
  margin-top: 16px;
}

.sku-info {
  margin-top: 4px;
  color: var(--gray);
  font-size: 12px;
}

.warn-variant {
  color: #f39c12;
}

/* Quantity and Buttons */
.actions-section {
  display: flex;
  gap: 20px;
  align-items: center;
}

.quantity-selector {
  display: flex;
  align-items: center;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
}

.qty-btn {
  background: transparent;
  border: none;
  font-size: 18px;
  font-weight: 700;
  padding: 10px 16px;
  cursor: pointer;
}

.qty-input {
  width: 50px;
  text-align: center;
  border: none;
  font-size: 16px;
  font-weight: 700;
  padding: 0;
}

.add-to-cart-btn {
  flex: 1;
}

/* Reviews List Styles */
.reviews-section {
  border-top: 1px solid var(--border);
  margin-top: 60px;
}

.review-form-card {
  margin-bottom: 40px;
}

.review-form-card h3 {
  margin-bottom: 20px;
}

.star-selector {
  display: flex;
  gap: 8px;
  font-size: 28px;
}

.star-opt {
  cursor: pointer;
  color: var(--border);
  transition: var(--transition);
}

.star-opt.active {
  color: #f39c12;
}

.review-login-prompt {
  text-align: center;
  padding: 24px;
  margin-bottom: 40px;
}

.review-login-prompt a {
  color: var(--primary);
  font-weight: 700;
}

.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.review-item {
  padding: 20px;
}

.review-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
  font-size: 13px;
  font-weight: 600;
}

.star-empty {
  color: var(--border);
}

.review-date {
  color: var(--gray);
}

.review-comment {
  color: var(--gray-dark);
}

.no-reviews {
  text-align: center;
  padding: 40px;
  color: var(--gray);
}

.loader {
  text-align: center;
  padding: 120px 0;
  font-size: 18px;
  color: var(--gray);
}

@media (max-width: 768px) {
  .detail-container {
    grid-template-columns: 1fr;
  }
  .main-image-wrapper {
    height: 400px;
  }
}
</style>

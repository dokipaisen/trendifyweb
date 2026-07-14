<template>
  <div class="app-layout">
    <!-- Notifications banner -->
    <div v-if="authStore.success || cartStore.success" class="toast success-toast">
      <span>{{ authStore.success || cartStore.success }}</span>
      <button @click="clearToasts" class="toast-close">&times;</button>
    </div>
    <div v-if="authStore.error || cartStore.error" class="toast error-toast">
      <span>{{ authStore.error || cartStore.error }}</span>
      <button @click="clearToasts" class="toast-close">&times;</button>
    </div>

    <!-- Header Navbar -->
    <header class="main-header" v-if="!isAdminRoute">
      <div class="container header-container">
        <router-link to="/" class="logo">
          <span class="logo-gold">Trend</span>ify
        </router-link>
        
        <nav class="nav-links">
          <router-link to="/" active-class="active-nav">Trang chủ</router-link>
          <router-link to="/shop" active-class="active-nav">Cửa hàng</router-link>
          <router-link to="/support" active-class="active-nav">Hỗ trợ</router-link>
        </nav>
        
        <div class="header-actions">
          <router-link to="/cart" class="cart-btn">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
            <span v-if="cartStore.totalQuantity > 0" class="cart-badge">{{ cartStore.totalQuantity }}</span>
          </router-link>

          <template v-if="authStore.isLoggedIn">
            <div class="user-menu-container">
              <button @click="toggleUserMenu" class="user-btn">
                <span class="user-name">{{ authStore.user.fullName }}</span>
              </button>
              
              <div v-if="showUserMenu" class="dropdown-menu">
                <router-link to="/profile" @click="showUserMenu = false">Hồ sơ cá nhân</router-link>
                <router-link v-if="authStore.isAdmin" to="/admin" @click="showUserMenu = false">Quản trị viên</router-link>
                <button @click="handleLogout" class="dropdown-logout">Đăng xuất</button>
              </div>
            </div>
          </template>
          <template v-else>
            <router-link to="/login" class="btn btn-dark btn-sm">Đăng nhập</router-link>
          </template>
        </div>
      </div>
    </header>

    <!-- Main Content Area -->
    <main class="main-content">
      <router-view />
    </main>

    <!-- Footer -->
    <footer class="main-footer" v-if="!isAdminRoute">
      <div class="container footer-container">
        <div class="footer-brand">
          <h3><span class="logo-gold">Trend</span>ify</h3>
          <p>Thương hiệu thời trang cao cấp hàng đầu dành cho giới trẻ hiện đại.</p>
        </div>
        <div class="footer-links">
          <h4>Liên kết nhanh</h4>
          <router-link to="/">Trang chủ</router-link>
          <router-link to="/shop">Cửa hàng</router-link>
          <router-link to="/support">Hỗ trợ</router-link>
        </div>
        <div class="footer-contact">
          <h4>Liên hệ</h4>
          <p>Email: support@trendify.com</p>
          <p>Hotline: 1900 8198</p>
          <p>Địa chỉ: Hà Nội, Việt Nam</p>
        </div>
      </div>
      <div class="footer-bottom">
        <p>&copy; 2026 Trendify Store. All rights reserved.</p>
      </div>
    </footer>

    <!-- Global Chat Widget -->
    <ChatWidget v-if="!isAdminRoute" />
  </div>
</template>

<script>
import { ref, computed, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from './stores/auth';
import { useCartStore } from './stores/cart';
import ChatWidget from './components/ChatWidget.vue';

export default {
  name: 'App',
  components: {
    ChatWidget
  },
  setup() {
    const route = useRoute();
    const router = useRouter();
    const authStore = useAuthStore();
    const cartStore = useCartStore();
    
    const showUserMenu = ref(false);
    
    const isAdminRoute = computed(() => {
      return route.path.startsWith('/admin');
    });

    const toggleUserMenu = () => {
      showUserMenu.value = !showUserMenu.value;
    };

    const handleLogout = async () => {
      showUserMenu.value = false;
      await authStore.logout();
      cartStore.clearCart();
      router.push('/');
    };

    const clearToasts = () => {
      authStore.clearMessages();
      cartStore.error = null;
      cartStore.success = null;
    };

    // Auto-clear message toasts after 4 seconds
    watch(() => [authStore.success, authStore.error, cartStore.success, cartStore.error], (newVals) => {
      if (newVals.some(v => v !== null)) {
        setTimeout(clearToasts, 4000);
      }
    }, { deep: true });

    return {
      authStore,
      cartStore,
      showUserMenu,
      isAdminRoute,
      toggleUserMenu,
      handleLogout,
      clearToasts
    };
  }
};
</script>

<style scoped>
.app-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.main-content {
  flex: 1;
}

/* Header design */
.main-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  position: sticky;
  top: 0;
  z-index: 100;
  border-bottom: 1px solid rgba(197, 168, 128, 0.15);
  box-shadow: var(--shadow-sm);
}

.header-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 80px;
}

.logo {
  font-size: 26px;
  font-weight: 800;
  font-family: var(--font-heading);
  letter-spacing: 1px;
}

.logo-gold {
  color: var(--primary);
}

.nav-links {
  display: flex;
  gap: 32px;
}

.nav-links a {
  font-weight: 600;
  font-size: 15px;
  color: var(--dark-light);
  position: relative;
  padding: 8px 0;
}

.nav-links a::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 0;
  height: 2px;
  background: var(--primary);
  transition: var(--transition);
}

.nav-links a:hover::after,
.nav-links a.active-nav::after {
  width: 100%;
}

.nav-links a.active-nav {
  color: var(--primary);
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 20px;
}

.cart-btn {
  font-size: 22px;
  position: relative;
  padding: 8px;
  display: flex;
  align-items: center;
}

.cart-badge {
  position: absolute;
  top: -2px;
  right: -2px;
  background: var(--primary);
  color: var(--white);
  font-size: 11px;
  font-weight: 700;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.user-menu-container {
  position: relative;
}

.user-btn {
  background: var(--gray-light);
  border: none;
  border-radius: var(--radius);
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  font-weight: 600;
}

.user-name {
  max-width: 120px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  background: var(--white);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow-lg);
  padding: 12px 0;
  min-width: 180px;
  margin-top: 8px;
  display: flex;
  flex-direction: column;
}

.dropdown-menu a, .dropdown-logout {
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 500;
  text-align: left;
  width: 100%;
  background: transparent;
  border: none;
}

.dropdown-menu a:hover, .dropdown-logout:hover {
  background-color: var(--gray-light);
  color: var(--primary);
}

.dropdown-logout {
  color: #e74c3c;
  border-top: 1px solid var(--gray-light);
  margin-top: 4px;
  padding-top: 12px;
}

/* Footer design */
.main-footer {
  background-color: var(--dark);
  color: #bbbbbb;
  padding: 60px 0 20px 0;
  border-top: 3px solid var(--primary);
}

.footer-container {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  gap: 60px;
  margin-bottom: 40px;
}

.footer-brand h3 {
  color: var(--white);
  font-size: 24px;
  margin-bottom: 16px;
}

.footer-brand p {
  font-size: 14px;
  max-width: 320px;
}

.footer-links h4, .footer-contact h4 {
  color: var(--white);
  font-size: 16px;
  margin-bottom: 20px;
  text-transform: uppercase;
}

.footer-links a {
  display: block;
  margin-bottom: 12px;
  font-size: 14px;
}

.footer-links a:hover {
  color: var(--primary);
  padding-left: 5px;
}

.footer-contact p {
  font-size: 14px;
  margin-bottom: 12px;
}

.footer-bottom {
  text-align: center;
  border-top: 1px solid rgba(255,255,255,0.1);
  padding-top: 20px;
  font-size: 13px;
}

/* Toast design */
.toast {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 1000;
  padding: 16px 28px;
  border-radius: var(--radius);
  box-shadow: var(--shadow-lg);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  min-width: 300px;
  animation: slideIn 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  font-weight: 600;
}

.success-toast {
  background: #2ecc71;
  color: var(--white);
}

.error-toast {
  background: #e74c3c;
  color: var(--white);
}

.toast-close {
  background: transparent;
  border: none;
  color: var(--white);
  font-size: 20px;
  cursor: pointer;
  padding: 0;
}

@keyframes slideIn {
  from { transform: translateX(120%); }
  to { transform: translateX(0); }
}

@media (max-width: 768px) {
  .footer-container {
    grid-template-columns: 1fr;
    gap: 30px;
  }
  .nav-links {
    display: none;
  }
}
</style>

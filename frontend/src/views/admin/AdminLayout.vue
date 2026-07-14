<template>
  <div class="admin-layout-container">
    <!-- Admin Sidebar -->
    <aside class="admin-sidebar">
      <div class="sidebar-brand">
        <router-link to="/">
          <span class="gold-txt">Trend</span>ify <small>Admin</small>
        </router-link>
      </div>

      <div class="admin-user-info">
        <div class="avatar">U</div>
        <div>
          <h4>{{ authStore.user?.fullName }}</h4>
          <span class="role-badge" :class="authStore.user?.role.toLowerCase()">
            {{ authStore.user?.role }}
          </span>
        </div>
      </div>

      <nav class="sidebar-nav">
        <!-- Dashboard (Only strict admin) -->
        <router-link 
          v-if="authStore.user?.role === 'ADMIN'" 
          to="/admin/dashboard" 
          active-class="active"
        >
          Dashboard Thống kê
        </router-link>

        <!-- Product Management (All staff) -->
        <router-link to="/admin/products" active-class="active">
          Quản lý Sản phẩm
        </router-link>

        <!-- Category Management (All staff) -->
        <router-link to="/admin/categories" active-class="active">
          Quản lý Danh mục
        </router-link>

        <!-- Order Management (All staff) -->
        <router-link to="/admin/orders" active-class="active">
          Quản lý Đơn hàng
        </router-link>

        <!-- Voucher Management (Only strict admin) -->
        <router-link 
          v-if="authStore.user?.role === 'ADMIN'" 
          to="/admin/promotions" 
          active-class="active"
        >
          Quản lý Khuyến mãi
        </router-link>

        <!-- User Accounts Management (Only strict admin) -->
        <router-link 
          v-if="authStore.user?.role === 'ADMIN'" 
          to="/admin/users" 
          active-class="active"
        >
          Quản lý Người dùng
        </router-link>

        <!-- Support Chat (All staff) -->
        <router-link to="/admin/support" active-class="active">
          Chat Hỗ trợ
        </router-link>
      </nav>

      <div class="sidebar-footer">
        <router-link to="/" class="btn btn-outline btn-sm client-shop-btn">
          Về cửa hàng
        </router-link>
        <button @click="handleLogout" class="logout-btn">Đăng xuất</button>
      </div>
    </aside>

    <!-- Admin Main Body -->
    <div class="admin-main">
      <header class="admin-header">
        <h2>Khu vực Quản trị Hệ thống</h2>
        <span class="system-time">Thời gian hệ thống: {{ currentYear }}</span>
      </header>

      <main class="admin-viewport">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script>
import { useRouter } from 'vue-router';
import { useAuthStore } from '../../stores/auth';
import { useCartStore } from '../../stores/cart';

export default {
  name: 'AdminLayout',
  setup() {
    const router = useRouter();
    const authStore = useAuthStore();
    const cartStore = useCartStore();

    const currentYear = new Date().getFullYear();

    const handleLogout = async () => {
      await authStore.logout();
      cartStore.clearCart();
      router.push('/');
    };

    return {
      authStore,
      currentYear,
      handleLogout
    };
  }
};
</script>

<style scoped>
.admin-layout-container {
  display: grid;
  grid-template-columns: 260px 1fr;
  min-height: 100vh;
  background-color: #f7f6f2;
}

/* Sidebar Styling */
.admin-sidebar {
  background-color: #1a1a1a;
  color: #c8c8c8;
  display: flex;
  flex-direction: column;
  padding: 30px 20px;
  border-right: 2px solid var(--primary);
}

.sidebar-brand {
  font-size: 24px;
  font-weight: 800;
  font-family: var(--font-heading);
  margin-bottom: 35px;
  text-align: center;
  color: var(--white);
}

.sidebar-brand small {
  font-size: 12px;
  color: var(--primary);
  display: block;
  font-weight: 400;
}

.gold-txt {
  color: var(--primary);
}

.admin-user-info {
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 16px;
  background-color: #262626;
  border-radius: var(--radius);
  margin-bottom: 30px;
}

.admin-user-info h4 {
  color: var(--white);
  font-size: 14px;
  margin-bottom: 2px;
}

.avatar {
  font-size: 28px;
  background-color: #333333;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.role-badge {
  font-size: 10px;
  font-weight: 700;
  padding: 2px 6px;
  border-radius: 10px;
  text-transform: uppercase;
}

.role-badge.admin {
  background-color: #e74c3c;
  color: var(--white);
}

.role-badge.employee {
  background-color: #3498db;
  color: var(--white);
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
}

.sidebar-nav a {
  padding: 14px 18px;
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-weight: 600;
  transition: var(--transition);
}

.sidebar-nav a:hover {
  background-color: #2c2c2c;
  color: var(--primary);
}

.sidebar-nav a.active {
  background-color: var(--primary);
  color: var(--white);
}

.sidebar-footer {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 30px;
  border-top: 1px solid #333;
  padding-top: 20px;
}

.client-shop-btn {
  border-color: #444;
  color: #c8c8c8;
}

.client-shop-btn:hover {
  border-color: var(--primary);
}

.logout-btn {
  background: transparent;
  border: none;
  color: #e74c3c;
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
  padding: 8px;
}

/* Main Content Styling */
.admin-main {
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
}

.admin-header {
  height: 80px;
  background-color: var(--white);
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 40px;
}

.admin-header h2 {
  font-size: 20px;
}

.system-time {
  font-size: 13px;
  color: var(--gray);
}

.admin-viewport {
  flex: 1;
  padding: 40px;
  overflow-y: auto;
}

@media (max-width: 992px) {
  .admin-layout-container {
    grid-template-columns: 1fr;
  }
  .admin-sidebar {
    height: auto;
  }
  .admin-main {
    height: auto;
    overflow: visible;
  }
}
</style>

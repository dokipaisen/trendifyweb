import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '../stores/auth';

import HomeView from '../views/HomeView.vue';
import ShopView from '../views/ShopView.vue';
import ProductDetailView from '../views/ProductDetailView.vue';
import CartView from '../views/CartView.vue';
import CheckoutView from '../views/CheckoutView.vue';
import LoginView from '../views/LoginView.vue';
import RegisterView from '../views/RegisterView.vue';
import ProfileView from '../views/ProfileView.vue';
import SupportView from '../views/SupportView.vue';

// Admin Views
import AdminLayout from '../views/admin/AdminLayout.vue';
import DashboardView from '../views/admin/DashboardView.vue';
import ProductManagementView from '../views/admin/ProductManagementView.vue';
import CategoryManagementView from '../views/admin/CategoryManagementView.vue';
import OrderManagementView from '../views/admin/OrderManagementView.vue';
import PromotionManagementView from '../views/admin/PromotionManagementView.vue';
import UserManagementView from '../views/admin/UserManagementView.vue';
import SupportChatManagementView from '../views/admin/SupportChatManagementView.vue';

const routes = [
  { path: '/', name: 'home', component: HomeView },
  { path: '/shop', name: 'shop', component: ShopView },
  { path: '/products/:id', name: 'product-detail', component: ProductDetailView },
  { path: '/cart', name: 'cart', component: CartView },
  { path: '/checkout', name: 'checkout', component: CheckoutView, meta: { requiresAuth: true } },
  { path: '/login', name: 'login', component: LoginView, meta: { guestOnly: true } },
  { path: '/register', name: 'register', component: RegisterView, meta: { guestOnly: true } },
  { path: '/profile', name: 'profile', component: ProfileView, meta: { requiresAuth: true } },
  { path: '/support', name: 'support', component: SupportView },
  
  // Admin Routes
  {
    path: '/admin',
    component: AdminLayout,
    meta: { requiresAuth: true, requiresStaff: true },
    children: [
      { path: '', redirect: '/admin/dashboard' },
      { path: 'dashboard', name: 'admin-dashboard', component: DashboardView, meta: { requiresAdminOnly: true } },
      { path: 'products', name: 'admin-products', component: ProductManagementView },
      { path: 'categories', name: 'admin-categories', component: CategoryManagementView },
      { path: 'orders', name: 'admin-orders', component: OrderManagementView },
      { path: 'promotions', name: 'admin-promotions', component: PromotionManagementView, meta: { requiresAdminOnly: true } },
      { path: 'users', name: 'admin-users', component: UserManagementView, meta: { requiresAdminOnly: true } },
      { path: 'support', name: 'admin-support', component: SupportChatManagementView }
    ]
  },
  
  // Wildcard redirect
  { path: '/:pathMatch(.*)*', redirect: '/' }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 };
  }
});

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore();
  
  // Fetch fresh user data once if page refreshes
  if (authStore.user && !authStore.loading) {
    // optional: verify user session with /me on load
  }

  const isLoggedIn = authStore.isLoggedIn;
  const isStaff = authStore.isAdmin;
  const isStrictAdmin = authStore.isStrictAdmin;

  if (to.meta.requiresAuth && !isLoggedIn) {
    next({ name: 'login', query: { redirect: to.fullPath } });
  } else if (to.meta.guestOnly && isLoggedIn) {
    next({ name: 'home' });
  } else if (to.meta.requiresStaff && !isStaff) {
    next({ name: 'home' });
  } else if (to.meta.requiresAdminOnly && !isStrictAdmin) {
    // Employee tries to access statistics, promotions, or users management
    // Redirect employee back to products management page
    next({ name: 'admin-products' });
  } else {
    next();
  }
});

export default router;

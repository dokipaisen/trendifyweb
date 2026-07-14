<template>
  <div class="login-page fade-in">
    <div class="container form-container card">
      <h2>Đăng nhập tài khoản</h2>
      <p class="subtitle">Chào mừng bạn quay lại với Trendify</p>

      <!-- Error banner -->
      <div v-if="authStore.error" class="alert alert-error">
        {{ authStore.error }}
      </div>

      <form @submit.prevent="submitLogin">
        <div class="form-group">
          <label for="username">Tên đăng nhập</label>
          <input 
            type="text" 
            id="username" 
            v-model="username" 
            required 
            placeholder="Tên đăng nhập của bạn..."
            class="form-control"
          >
        </div>

        <div class="form-group">
          <label for="password">Mật khẩu</label>
          <input 
            type="password" 
            id="password" 
            v-model="password" 
            required 
            placeholder="Mật khẩu..."
            class="form-control"
          >
        </div>

        <button type="submit" class="btn btn-primary login-btn" :disabled="authStore.loading">
          {{ authStore.loading ? 'Đang xử lý...' : 'Đăng Nhập' }}
        </button>
      </form>

      <div class="form-footer">
        <p>Bạn chưa có tài khoản? <router-link to="/register">Đăng ký ngay</router-link></p>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { useCartStore } from '../stores/cart';

export default {
  name: 'LoginView',
  setup() {
    const router = useRouter();
    const route = useRoute();
    const authStore = useAuthStore();
    const cartStore = useCartStore();

    const username = ref('');
    const password = ref('');

    const submitLogin = async () => {
      try {
        const user = await authStore.login(username.value, password.value);
        
        // Merge guest cart items into user's cart in db
        await cartStore.mergeCartOnLogin();

        // Redirect based on roles or query redirect
        const redirectPath = route.query.redirect;
        if (redirectPath) {
          router.push(redirectPath);
        } else {
          if (user.role === 'ADMIN' || user.role === 'EMPLOYEE') {
            // If employee, router handles redirection to products page
            router.push('/admin');
          } else {
            router.push('/');
          }
        }
      } catch (err) {
        // Handled by store
      }
    };

    onMounted(() => {
      authStore.clearMessages();
    });

    return {
      authStore,
      username,
      password,
      submitLogin
    };
  }
};
</script>

<style scoped>
.login-page {
  padding: 80px 0;
  display: flex;
  justify-content: center;
  align-items: center;
}

.form-container {
  max-width: 450px;
  width: 100%;
}

.form-container h2 {
  font-size: 28px;
  margin-bottom: 8px;
  text-align: center;
}

.subtitle {
  text-align: center;
  color: var(--gray);
  font-size: 14px;
  margin-bottom: 30px;
}

.login-btn {
  width: 100%;
  margin-top: 15px;
  padding: 14px;
}

.form-footer {
  text-align: center;
  margin-top: 24px;
  font-size: 14px;
}

.form-footer a {
  color: var(--primary);
  font-weight: 700;
}
</style>

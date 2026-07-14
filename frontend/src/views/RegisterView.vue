<template>
  <div class="register-page fade-in">
    <div class="container form-container card">
      <h2>Đăng ký tài khoản</h2>
      <p class="subtitle">Trở thành thành viên của gia đình Trendify</p>

      <!-- Error banner -->
      <div v-if="authStore.error" class="alert alert-error">
        {{ authStore.error }}
      </div>

      <form @submit.prevent="submitRegister">
        <div class="form-group">
          <label for="username">Tên đăng nhập *</label>
          <input 
            type="text" 
            id="username" 
            v-model="userForm.username" 
            required 
            placeholder="Tên đăng nhập duy nhất..."
            class="form-control"
          >
        </div>

        <div class="form-group">
          <label for="password">Mật khẩu *</label>
          <input 
            type="password" 
            id="password" 
            v-model="userForm.password" 
            required 
            placeholder="Mật khẩu bảo mật..."
            class="form-control"
          >
        </div>

        <div class="form-group">
          <label for="fullName">Họ và tên *</label>
          <input 
            type="text" 
            id="fullName" 
            v-model="userForm.fullName" 
            required 
            placeholder="Nhập đầy đủ họ tên..."
            class="form-control"
          >
        </div>

        <div class="form-group">
          <label for="email">Địa chỉ Email *</label>
          <input 
            type="email" 
            id="email" 
            v-model="userForm.email" 
            required 
            placeholder="ví dụ: customer@gmail.com"
            class="form-control"
          >
        </div>

        <div class="form-group">
          <label for="phone">Số điện thoại</label>
          <input 
            type="tel" 
            id="phone" 
            v-model="userForm.phone" 
            placeholder="Nhập số điện thoại..."
            class="form-control"
          >
        </div>

        <div class="form-group">
          <label for="address">Địa chỉ mặc định</label>
          <input 
            type="text" 
            id="address" 
            v-model="userForm.address" 
            placeholder="Nhập địa chỉ nhà..."
            class="form-control"
          >
        </div>

        <button type="submit" class="btn btn-primary register-btn" :disabled="authStore.loading">
          {{ authStore.loading ? 'Đang xử lý...' : 'Đăng Ký Tài Khoản' }}
        </button>
      </form>

      <div class="form-footer">
        <p>Bạn đã có tài khoản? <router-link to="/login">Đăng nhập</router-link></p>
      </div>
    </div>
  </div>
</template>

<script>
import { reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';

export default {
  name: 'RegisterView',
  setup() {
    const router = useRouter();
    const authStore = useAuthStore();

    const userForm = reactive({
      username: '',
      password: '',
      fullName: '',
      email: '',
      phone: '',
      address: ''
    });

    const submitRegister = async () => {
      try {
        await authStore.register({ ...userForm });
        // Redirect to login after successful registration
        router.push('/login');
      } catch (err) {
        // Handled by store
      }
    };

    onMounted(() => {
      authStore.clearMessages();
    });

    return {
      authStore,
      userForm,
      submitRegister
    };
  }
};
</script>

<style scoped>
.register-page {
  padding: 60px 0;
  display: flex;
  justify-content: center;
  align-items: center;
}

.form-container {
  max-width: 500px;
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

.register-btn {
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

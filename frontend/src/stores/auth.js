import { defineStore } from 'pinia';
import axios from 'axios';

// Configure axios globally for credentials and API URL
axios.defaults.baseURL = 'http://localhost:8080';
axios.defaults.withCredentials = true;

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('currentUser') || 'null'),
    loading: false,
    error: null,
    success: null
  }),
  
  getters: {
    isLoggedIn: (state) => state.user !== null,
    isAdmin: (state) => state.user && (state.user.role === 'ADMIN' || state.user.role === 'EMPLOYEE'),
    isStrictAdmin: (state) => state.user && state.user.role === 'ADMIN',
  },

  actions: {
    clearMessages() {
      this.error = null;
      this.success = null;
    },

    async fetchMe() {
      try {
        const response = await axios.get('/api/auth/me');
        this.user = response.data;
        localStorage.setItem('currentUser', JSON.stringify(this.user));
      } catch (err) {
        this.user = null;
        localStorage.removeItem('currentUser');
      }
    },

    async login(username, password) {
      this.loading = true;
      this.error = null;
      try {
        const response = await axios.post('/api/auth/login', { username, password });
        this.user = response.data;
        localStorage.setItem('currentUser', JSON.stringify(this.user));
        this.success = 'Đăng nhập thành công!';
        return this.user;
      } catch (err) {
        this.error = err.response?.data?.message || 'Tên đăng nhập hoặc mật khẩu không chính xác.';
        throw err;
      } finally {
        this.loading = false;
      }
    },

    async register(userData) {
      this.loading = true;
      this.error = null;
      try {
        await axios.post('/api/auth/register', userData);
        this.success = 'Đăng ký thành công! Vui lòng đăng nhập.';
      } catch (err) {
        this.error = err.response?.data?.message || 'Có lỗi xảy ra khi đăng ký tài khoản.';
        throw err;
      } finally {
        this.loading = false;
      }
    },

    async logout() {
      try {
        await axios.post('/api/auth/logout');
      } catch (e) {
        console.error('Logout API failed:', e);
      } finally {
        this.user = null;
        localStorage.removeItem('currentUser');
        this.success = 'Bạn đã đăng xuất thành công.';
      }
    },

    async updateProfile(profileData) {
      this.loading = true;
      this.error = null;
      this.success = null;
      try {
        const response = await axios.put('/api/auth/profile', profileData);
        this.user = response.data;
        localStorage.setItem('currentUser', JSON.stringify(this.user));
        this.success = 'Cập nhật thông tin cá nhân thành công.';
      } catch (err) {
        this.error = err.response?.data?.message || 'Cập nhật thông tin thất bại.';
        throw err;
      } finally {
        this.loading = false;
      }
    },

    async changePassword(oldPassword, newPassword) {
      this.loading = true;
      this.error = null;
      this.success = null;
      try {
        await axios.put('/api/auth/change-password', { oldPassword, newPassword });
        this.success = 'Đổi mật khẩu thành công.';
      } catch (err) {
        this.error = err.response?.data?.message || 'Đổi mật khẩu thất bại.';
        throw err;
      } finally {
        this.loading = false;
      }
    }
  }
});

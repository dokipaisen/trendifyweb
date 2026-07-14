import { defineStore } from 'pinia';
import axios from 'axios';
import { useAuthStore } from './auth';

export const useCartStore = defineStore('cart', {
  state: () => ({
    items: [],
    appliedVoucher: JSON.parse(localStorage.getItem('appliedVoucher') || 'null'),
    error: null,
    success: null
  }),

  getters: {
    totalQuantity: (state) => state.items.reduce((total, item) => total + item.quantity, 0),
    subtotal: (state) => state.items.reduce((total, item) => total + (item.price * item.quantity), 0),
    discountAmount: (state) => {
      if (!state.appliedVoucher) return 0;
      const sub = state.items.reduce((total, item) => total + (item.price * item.quantity), 0);
      if (sub < state.appliedVoucher.minOrderValue) return 0;

      if (state.appliedVoucher.discountType === 'PERCENTAGE') {
        const val = sub * (state.appliedVoucher.discountValue / 100);
        if (state.appliedVoucher.maxDiscount && val > state.appliedVoucher.maxDiscount) {
          return state.appliedVoucher.maxDiscount;
        }
        return val;
      } else if (state.appliedVoucher.discountType === 'FIXED_AMOUNT') {
        return state.appliedVoucher.discountValue;
      }
      return 0;
    },
    totalAmount: (state) => {
      const sub = state.items.reduce((total, item) => total + (item.price * item.quantity), 0);
      const disc = state.items.reduce((total, item) => total + (item.price * item.quantity), 0); // placeholder for state access
      // Call state/getter logic properly
      let val = sub - state.items.reduce((total, item) => total + (item.price * item.quantity), 0); // recalculating to be safe
      
      // Let's use simple logic:
      let discountVal = 0;
      if (state.appliedVoucher && sub >= state.appliedVoucher.minOrderValue) {
        if (state.appliedVoucher.discountType === 'PERCENTAGE') {
          discountVal = sub * (state.appliedVoucher.discountValue / 100);
          if (state.appliedVoucher.maxDiscount && discountVal > state.appliedVoucher.maxDiscount) {
            discountVal = state.appliedVoucher.maxDiscount;
          }
        } else if (state.appliedVoucher.discountType === 'FIXED_AMOUNT') {
          discountVal = state.appliedVoucher.discountValue;
        }
      }
      const total = sub - discountVal;
      return total < 0 ? 0 : total;
    }
  },

  actions: {
    async initCart() {
      const authStore = useAuthStore();
      if (authStore.isLoggedIn) {
        await this.fetchCart();
      } else {
        this.items = JSON.parse(localStorage.getItem('guestCart') || '[]');
      }
    },

    async fetchCart() {
      const authStore = useAuthStore();
      if (!authStore.isLoggedIn) return;
      try {
        const response = await axios.get('/api/cart');
        this.items = response.data;
      } catch (err) {
        console.error('Fetch cart failed:', err);
      }
    },

    async addToCart(product, variant, quantity) {
      const authStore = useAuthStore();
      if (authStore.isLoggedIn) {
        try {
          await axios.post('/api/cart/add', {
            productId: product.id,
            variantId: variant.id,
            quantity: quantity
          });
          await this.fetchCart();
        } catch (err) {
          console.error(err);
          throw err;
        }
      } else {
        // Guest mode
        const existing = this.items.find(item => item.variantId === variant.id);
        if (existing) {
          existing.quantity += quantity;
        } else {
          this.items.push({
            productId: product.id,
            variantId: variant.id,
            quantity: quantity,
            productName: product.name,
            productBrand: product.brand,
            productImageUrl: product.imageUrl,
            price: product.price,
            size: variant.size,
            color: variant.color
          });
        }
        localStorage.setItem('guestCart', JSON.stringify(this.items));
      }
      this.success = 'Đã thêm sản phẩm vào giỏ hàng!';
    },

    async updateQuantity(variantId, quantity) {
      const authStore = useAuthStore();
      if (authStore.isLoggedIn) {
        try {
          await axios.put(`/api/cart/quantity?variantId=${variantId}&quantity=${quantity}`);
          await this.fetchCart();
        } catch (err) {
          console.error(err);
        }
      } else {
        const existing = this.items.find(item => item.variantId === variantId);
        if (existing) {
          existing.quantity = quantity;
          localStorage.setItem('guestCart', JSON.stringify(this.items));
        }
      }
    },

    async removeFromCart(variantId) {
      const authStore = useAuthStore();
      if (authStore.isLoggedIn) {
        try {
          await axios.delete(`/api/cart/remove?variantId=${variantId}`);
          await this.fetchCart();
        } catch (err) {
          console.error(err);
        }
      } else {
        this.items = this.items.filter(item => item.variantId !== variantId);
        localStorage.setItem('guestCart', JSON.stringify(this.items));
      }
    },

    async clearCart() {
      const authStore = useAuthStore();
      if (authStore.isLoggedIn) {
        try {
          await axios.delete('/api/cart/clear');
          this.items = [];
        } catch (err) {
          console.error(err);
        }
      } else {
        this.items = [];
        localStorage.removeItem('guestCart');
      }
      this.appliedVoucher = null;
      localStorage.removeItem('appliedVoucher');
    },

    async mergeCartOnLogin() {
      const guestCart = JSON.parse(localStorage.getItem('guestCart') || '[]');
      if (guestCart.length > 0) {
        try {
          await axios.post('/api/cart/merge', guestCart);
          localStorage.removeItem('guestCart');
        } catch (err) {
          console.error('Merge cart error:', err);
        }
      }
      await this.fetchCart();
    },

    async applyVoucher(code) {
      this.error = null;
      this.success = null;
      try {
        const response = await axios.get(`/api/promotions/check?code=${code}`);
        this.appliedVoucher = response.data;
        localStorage.setItem('appliedVoucher', JSON.stringify(this.appliedVoucher));
        this.success = 'Áp dụng mã giảm giá thành công!';
        return this.appliedVoucher;
      } catch (err) {
        this.appliedVoucher = null;
        localStorage.removeItem('appliedVoucher');
        this.error = err.response?.data?.message || 'Mã giảm giá không hợp lệ.';
        throw err;
      }
    },

    removeVoucher() {
      this.appliedVoucher = null;
      localStorage.removeItem('appliedVoucher');
      this.success = 'Đã xoá mã giảm giá.';
    }
  }
});

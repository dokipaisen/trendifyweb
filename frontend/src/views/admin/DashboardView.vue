<template>
  <div class="dashboard-page fade-in">
    <div class="page-header">
      <h1>Dashboard Thống kê Doanh thu</h1>
      <p>Theo dõi hiệu suất doanh thu bán hàng và nhân viên phụ trách.</p>
    </div>

    <!-- Stats Filter Widget -->
    <div class="card filter-card">
      <div class="filter-inputs-grid">
        <div class="form-group">
          <label>Từ ngày</label>
          <input type="date" v-model="filters.startDate" class="form-control">
        </div>
        <div class="form-group">
          <label>Đến ngày</label>
          <input type="date" v-model="filters.endDate" class="form-control">
        </div>
        <div class="form-group">
          <label>Tháng</label>
          <select v-model.number="filters.month" class="form-control">
            <option :value="null">Tất cả tháng</option>
            <option v-for="m in 12" :key="m" :value="m">Tháng {{ m }}</option>
          </select>
        </div>
        <div class="form-group">
          <label>Năm</label>
          <select v-model.number="filters.year" class="form-control">
            <option :value="null">Tất cả năm</option>
            <option v-for="y in [2024, 2025, 2026]" :key="y" :value="y">Năm {{ y }}</option>
          </select>
        </div>
      </div>
      <div class="filter-actions">
        <button @click="fetchStats" class="btn btn-primary">Lọc dữ liệu</button>
        <button @click="resetFilters" class="btn btn-outline">Làm mới</button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loader">Đang tính toán thống kê...</div>

    <!-- Statistics Cards -->
    <div v-else class="stats-overview-grid">
      <div class="stat-widget card">
        <div class="stat-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
        </div>
        <div>
          <h3>Doanh thu thuần</h3>
          <p class="stat-value">{{ formatCurrency(stats.totalRevenue) }}</p>
          <span class="stat-sub">Không tính đơn hàng bị hủy</span>
        </div>
      </div>

      <div class="stat-widget card">
        <div class="stat-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
        </div>
        <div>
          <h3>Đơn hàng hoàn thành</h3>
          <p class="stat-value">{{ stats.totalOrders }} đơn hàng</p>
          <span class="stat-sub">Đơn hàng ở trạng thái hợp lệ</span>
        </div>
      </div>
    </div>

    <!-- Employee Performance -->
    <div v-if="!loading" class="card performance-card">
      <h2>Hiệu suất bán hàng của Nhân viên</h2>
      <p class="subtitle">Thống kê doanh số bán hàng và số lượng đơn xử lý bởi nhân viên phụ trách.</p>

      <div class="performance-table-wrapper">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Tên Nhân viên</th>
              <th>Số Đơn hàng đã xử lý</th>
              <th>Doanh thu Mang lại</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="Object.keys(stats.staffPerformance || {}).length === 0">
              <td colspan="3" class="text-center text-gray">Chưa có dữ liệu xử lý đơn hàng của nhân viên.</td>
            </tr>
            <tr v-else v-for="(perf, name) in stats.staffPerformance" :key="name">
              <td><strong>{{ name }}</strong></td>
              <td>{{ perf.ordersCount }} đơn hàng</td>
              <td class="gold-bold">{{ formatCurrency(perf.revenue) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue';
import axios from 'axios';

export default {
  name: 'DashboardView',
  setup() {
    const stats = ref({
      totalRevenue: 0,
      totalOrders: 0,
      staffPerformance: {}
    });
    const loading = ref(true);

    const filters = reactive({
      startDate: '',
      endDate: '',
      month: null,
      year: new Date().getFullYear() // default to current year
    });

    const fetchStats = async () => {
      loading.value = true;
      try {
        const params = {};
        if (filters.startDate) params.startDate = filters.startDate;
        if (filters.endDate) params.endDate = filters.endDate;
        if (filters.month) params.month = filters.month;
        if (filters.year) params.year = filters.year;

        const response = await axios.get('/api/admin/statistics', { params });
        stats.value = response.data;
      } catch (err) {
        console.error('Lỗi tải thống kê:', err);
      } finally {
        loading.value = false;
      }
    };

    const resetFilters = () => {
      filters.startDate = '';
      filters.endDate = '';
      filters.month = null;
      filters.year = new Date().getFullYear();
      fetchStats();
    };

    const formatCurrency = (val) => {
      if (!val) return '0đ';
      return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
    };

    onMounted(() => {
      fetchStats();
    });

    return {
      stats,
      loading,
      filters,
      fetchStats,
      resetFilters,
      formatCurrency
    };
  }
};
</script>

<style scoped>
.page-header {
  margin-bottom: 30px;
}

.page-header h1 {
  font-size: 28px;
  margin-bottom: 6px;
}

.page-header p {
  color: var(--gray);
}

.filter-card {
  margin-bottom: 30px;
}

.filter-inputs-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.filter-actions {
  display: flex;
  gap: 16px;
}

.stats-overview-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 30px;
  margin-bottom: 40px;
}

.stat-widget {
  display: flex;
  gap: 20px;
  align-items: center;
  padding: 30px;
}

.stat-icon {
  font-size: 40px;
  width: 70px;
  height: 70px;
  background-color: var(--gray-light);
  border-radius: var(--radius);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--border);
}

.stat-widget h3 {
  font-size: 15px;
  color: var(--gray-dark);
  text-transform: uppercase;
  margin-bottom: 6px;
}

.stat-value {
  font-size: 28px;
  font-weight: 800;
  color: var(--dark);
}

.stat-sub {
  font-size: 11px;
  color: var(--gray);
}

.performance-card h2 {
  font-size: 20px;
  margin-bottom: 4px;
}

.performance-card .subtitle {
  color: var(--gray);
  font-size: 13px;
  margin-bottom: 24px;
}

/* Common Admin Table styling */
.performance-table-wrapper {
  overflow-x: auto;
}

.admin-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
  text-align: left;
}

.admin-table th, .admin-table td {
  padding: 14px 20px;
  border-bottom: 1px solid var(--border);
}

.admin-table th {
  background-color: var(--gray-light);
  font-weight: 700;
  color: var(--dark-light);
}

.admin-table tbody tr:hover {
  background-color: #faf9f6;
}

.gold-bold {
  font-weight: 700;
  color: var(--primary);
}

.text-center { text-align: center; }
.text-gray { color: var(--gray); }

.loader {
  text-align: center;
  padding: 60px;
  font-size: 18px;
}

@media (max-width: 992px) {
  .filter-inputs-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .stats-overview-grid {
    grid-template-columns: 1fr;
  }
}
</style>

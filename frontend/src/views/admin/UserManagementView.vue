<template>
  <div class="user-mgmt-page fade-in">
    <div class="page-header-row">
      <div>
        <h1>Quản lý Người dùng & Nhân viên</h1>
        <p>Phân quyền tài khoản (Admin, Nhân viên, Khách hàng) và quản trị trạng thái khóa.</p>
      </div>
      <button @click="openCreateModal" class="btn btn-primary">Thêm tài khoản mới</button>
    </div>

    <!-- Users Table -->
    <div class="card table-card">
      <div v-if="loading" class="loader">Đang tải danh sách người dùng...</div>
      
      <div v-else class="table-wrapper">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Username</th>
              <th>Họ và tên</th>
              <th>Email</th>
              <th>Số điện thoại</th>
              <th>Vai trò (Role)</th>
              <th>Trạng thái</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="users.length === 0">
              <td colspan="7" class="text-center text-gray">Không tìm thấy tài khoản nào.</td>
            </tr>
            <tr v-else v-for="u in users" :key="u.id">
              <td><strong>{{ u.username }}</strong></td>
              <td>{{ u.fullName }}</td>
              <td>{{ u.email }}</td>
              <td>{{ u.phone || 'Chưa cung cấp' }}</td>
              <td>
                <span class="role-badge" :class="u.role.toLowerCase()">
                  {{ u.role }}
                </span>
              </td>
              <td>
                <span class="badge" :class="u.status === 'ACTIVE' ? 'badge-success' : 'badge-danger'">
                  {{ u.status === 'ACTIVE' ? 'Hoạt động' : 'Bị khoá' }}
                </span>
              </td>
              <td>
                <div class="actions-group">
                  <button @click="openEditModal(u)" class="btn-action edit-btn">Sửa</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal Form (Create / Edit) -->
    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content card">
        <div class="modal-header">
          <h2>{{ isEditMode ? 'Cập nhật tài khoản' : 'Thêm tài khoản mới' }}</h2>
          <button @click="showModal = false" class="close-modal">&times;</button>
        </div>

        <form @submit.prevent="saveUser" class="modal-form">
          <div class="form-group">
            <label for="u-username">Tên đăng nhập (Username) *</label>
            <input 
              type="text" 
              id="u-username" 
              v-model="userForm.username" 
              required 
              class="form-control"
              :disabled="isEditMode"
            >
          </div>

          <div class="form-group" v-if="!isEditMode">
            <label for="u-password">Mật khẩu *</label>
            <input 
              type="password" 
              id="u-password" 
              v-model="userForm.password" 
              required 
              class="form-control"
            >
          </div>
          <div class="form-group" v-else>
            <label for="u-password-edit">Đổi mật khẩu mới (để trống nếu giữ nguyên)</label>
            <input 
              type="password" 
              id="u-password-edit" 
              v-model="userForm.password" 
              class="form-control"
              placeholder="Nhập mật khẩu mới nếu muốn thay đổi..."
            >
          </div>

          <div class="form-group">
            <label for="u-fullname">Họ và tên *</label>
            <input type="text" id="u-fullname" v-model="userForm.fullName" required class="form-control">
          </div>

          <div class="form-group">
            <label for="u-email">Email *</label>
            <input type="email" id="u-email" v-model="userForm.email" required class="form-control">
          </div>

          <div class="form-group">
            <label for="u-phone">Số điện thoại</label>
            <input type="tel" id="u-phone" v-model="userForm.phone" class="form-control">
          </div>

          <div class="form-group">
            <label for="u-address">Địa chỉ</label>
            <input type="text" id="u-address" v-model="userForm.address" class="form-control">
          </div>

          <div class="form-group">
            <label for="u-role">Vai trò (Role) *</label>
            <select id="u-role" v-model="userForm.role" required class="form-control">
              <option value="CUSTOMER">CUSTOMER (Khách hàng)</option>
              <option value="EMPLOYEE">EMPLOYEE (Nhân viên bán hàng)</option>
              <option value="ADMIN">ADMIN (Quản trị hệ thống)</option>
            </select>
          </div>

          <div class="form-group">
            <label for="u-status">Trạng thái</label>
            <select id="u-status" v-model="userForm.status" required class="form-control">
              <option value="ACTIVE">ACTIVE (Hoạt động)</option>
              <option value="INACTIVE">INACTIVE (Khoá tài khoản)</option>
            </select>
          </div>

          <div class="modal-actions">
            <button type="button" @click="showModal = false" class="btn btn-outline">Huỷ bỏ</button>
            <button type="submit" class="btn btn-primary">Lưu thông tin</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue';
import axios from 'axios';

export default {
  name: 'UserManagementView',
  setup() {
    const users = ref([]);
    const loading = ref(true);
    
    const showModal = ref(false);
    const isEditMode = ref(false);
    const editId = ref(null);

    const userForm = reactive({
      username: '',
      password: '',
      fullName: '',
      email: '',
      phone: '',
      address: '',
      role: 'CUSTOMER',
      status: 'ACTIVE'
    });

    const fetchUsers = async () => {
      loading.value = true;
      try {
        const response = await axios.get('/api/admin/users');
        users.value = response.data;
      } catch (err) {
        console.error('Lỗi tải người dùng:', err);
      } finally {
        loading.value = false;
      }
    };

    const openCreateModal = () => {
      isEditMode.value = false;
      editId.value = null;
      userForm.username = '';
      userForm.password = '';
      userForm.fullName = '';
      userForm.email = '';
      userForm.phone = '';
      userForm.address = '';
      userForm.role = 'CUSTOMER';
      userForm.status = 'ACTIVE';
      showModal.value = true;
    };

    const openEditModal = (u) => {
      isEditMode.value = true;
      editId.value = u.id;
      userForm.username = u.username;
      userForm.password = ''; // empty, don't display hashed pass
      userForm.fullName = u.fullName;
      userForm.email = u.email;
      userForm.phone = u.phone || '';
      userForm.address = u.address || '';
      userForm.role = u.role;
      userForm.status = u.status;
      showModal.value = true;
    };

    const saveUser = async () => {
      try {
        const payload = { ...userForm };
        if (isEditMode.value) {
          // If password field is empty, don't update it
          if (!payload.password.trim()) {
            delete payload.password;
          }
          await axios.put(`/api/admin/users/${editId.value}`, payload);
        } else {
          await axios.post('/api/admin/users', payload);
        }

        showModal.value = false;
        fetchUsers();
      } catch (err) {
        console.error(err);
        alert(err.response?.data?.message || 'Có lỗi xảy ra.');
      }
    };

    onMounted(() => {
      fetchUsers();
    });

    return {
      users,
      loading,
      showModal,
      isEditMode,
      userForm,
      openCreateModal,
      openEditModal,
      saveUser
    };
  }
};
</script>

<style scoped>
.page-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.page-header-row h1 {
  font-size: 28px;
  margin-bottom: 4px;
}

.page-header-row p {
  color: var(--gray);
}

.role-badge {
  font-size: 11px;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 12px;
  text-transform: uppercase;
  display: inline-block;
}

.role-badge.admin {
  background-color: #fdedec;
  color: #e74c3c;
}

.role-badge.employee {
  background-color: #eaf2f8;
  color: #3498db;
}

.role-badge.customer {
  background-color: #f5f5f5;
  color: var(--gray-dark);
}

.actions-group {
  display: flex;
  gap: 12px;
}

.btn-action {
  border: none;
  background: transparent;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
}

.edit-btn {
  color: #3498db;
}

/* Modal styling */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  width: 500px;
  padding: 30px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  border-bottom: 2px solid var(--gray-light);
  padding-bottom: 12px;
}

.close-modal {
  background: transparent;
  border: none;
  font-size: 28px;
  cursor: pointer;
  padding: 0;
  color: var(--gray);
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 24px;
}

.text-center { text-align: center; }
.text-gray { color: var(--gray); }

.loader {
  text-align: center;
  padding: 40px;
}
</style>

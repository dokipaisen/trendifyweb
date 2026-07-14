<template>
  <div class="support-mgmt-page fade-in">
    <div class="page-header">
      <h1>Hỗ trợ khách hàng</h1>
      <p>Danh sách các phiên hội thoại trực tuyến của khách hàng với AI trợ lý và Nhân viên.</p>
    </div>

    <div class="chat-dashboard card">
      <!-- Left sidebar: sessions list -->
      <div class="sessions-sidebar">
        <div class="sidebar-header">
          <h3>Hội thoại gần đây</h3>
          <button @click="fetchSessions" class="btn btn-outline btn-sm refresh-btn">Tải lại</button>
        </div>

        <div v-if="sessionsLoading" class="loader-sm">Đang tải danh sách...</div>
        
        <div v-else class="sessions-list">
          <div v-if="sessions.length === 0" class="empty-list-txt">Không có cuộc hội thoại nào.</div>
          
          <div 
            v-else
            v-for="session in sessions" 
            :key="session.chatSessionId" 
            class="session-item"
            :class="{ active: selectedSessionId === session.chatSessionId }"
            @click="selectSession(session.chatSessionId)"
          >
            <div class="session-info-row">
              <span class="session-title-name">{{ session.senderName }}</span>
              <span class="session-badge" :class="session.mode.toLowerCase()">
                {{ session.mode }}
              </span>
            </div>
            <p class="session-last-msg">{{ session.message }}</p>
          </div>
        </div>
      </div>

      <!-- Right panel: conversation messages -->
      <div class="chat-panel">
        <div v-if="!selectedSessionId" class="no-session-selected">
          <p>Chọn một cuộc hội thoại bên trái để bắt đầu trò chuyện.</p>
        </div>

        <div v-else class="active-chat-container">
          <div class="chat-panel-header">
            <div>
              <h3>Hội thoại: {{ activeSessionName }}</h3>
              <p class="session-id-txt">ID: {{ selectedSessionId }}</p>
            </div>
          </div>

          <!-- Message log -->
          <div class="chat-panel-body" ref="adminMessageBodyRef">
            <div v-if="messagesLoading" class="loader-sm">Đang tải tin nhắn...</div>
            <div v-else class="chat-message-list">
              <div 
                v-for="msg in messages" 
                :key="msg.id" 
                class="msg-bubble-wrapper"
                :class="msg.sender.toLowerCase()"
              >
                <div class="msg-sender-name">{{ msg.senderName }} ({{ msg.sender }})</div>
                <div class="msg-bubble">
                  <p>{{ msg.message }}</p>
                </div>
                <div class="msg-time">{{ formatTime(msg.createdAt) }}</div>
              </div>
            </div>
          </div>

          <!-- Message input -->
          <form @submit.prevent="sendAdminReply" class="chat-panel-footer">
            <input 
              type="text" 
              v-model="replyText" 
              placeholder="Nhập tin nhắn phản hồi..."
              class="form-control admin-chat-input"
              required
            >
            <button type="submit" class="btn btn-primary admin-chat-send-btn">Gửi</button>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted, nextTick } from 'vue';
import { useAuthStore } from '../../stores/auth';
import axios from 'axios';

export default {
  name: 'SupportChatManagementView',
  setup() {
    const authStore = useAuthStore();
    const sessions = ref([]);
    const messages = ref([]);
    const selectedSessionId = ref('');
    const activeSessionName = ref('');
    const replyText = ref('');
    
    const sessionsLoading = ref(true);
    const messagesLoading = ref(false);
    const adminMessageBodyRef = ref(null);
    
    let sessionsTimer = null;
    let messagesTimer = null;

    const fetchSessions = async () => {
      try {
        const response = await axios.get('/api/chat/admin/sessions');
        sessions.value = response.data;
      } catch (err) {
        console.error(err);
      } finally {
        sessionsLoading.value = false;
      }
    };

    const fetchMessages = async () => {
      if (!selectedSessionId.value) return;
      try {
        const response = await axios.get(`/api/chat/messages/${selectedSessionId.value}`);
        messages.value = response.data;
        scrollToBottom();
      } catch (err) {
        console.error(err);
      } finally {
        messagesLoading.value = false;
      }
    };

    const selectSession = (sessionId) => {
      selectedSessionId.value = sessionId;
      const found = sessions.value.find(s => s.chatSessionId === sessionId);
      activeSessionName.value = found ? found.senderName : 'Khach hang';
      
      messagesLoading.value = true;
      fetchMessages();

      // Start message polling for selected session
      stopMessagesPolling();
      messagesTimer = setInterval(fetchMessages, 3000);
    };

    const sendAdminReply = async () => {
      if (!replyText.value.trim() || !selectedSessionId.value) return;

      const textToSend = replyText.value.trim();
      replyText.value = '';

      const payload = {
        chatSessionId: selectedSessionId.value,
        message: textToSend,
        senderName: authStore.user ? authStore.user.fullName : 'Nhan vien ho tro'
      };

      try {
        const res = await axios.post('/api/chat/admin/reply', payload);
        messages.value.push(res.data);
        scrollToBottom();
        // Update local session list preview
        fetchSessions();
      } catch (err) {
        console.error(err);
        alert('Gui tin nhan loi.');
      }
    };

    const scrollToBottom = () => {
      nextTick(() => {
        if (adminMessageBodyRef.value) {
          adminMessageBodyRef.value.scrollTop = adminMessageBodyRef.value.scrollHeight;
        }
      });
    };

    const startSessionsPolling = () => {
      stopSessionsPolling();
      sessionsTimer = setInterval(fetchSessions, 5000);
    };

    const stopSessionsPolling = () => {
      if (sessionsTimer) {
        clearInterval(sessionsTimer);
        sessionsTimer = null;
      }
    };

    const stopMessagesPolling = () => {
      if (messagesTimer) {
        clearInterval(messagesTimer);
        messagesTimer = null;
      }
    };

    const formatTime = (dateStr) => {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
    };

    onMounted(() => {
      fetchSessions();
      startSessionsPolling();
    });

    onUnmounted(() => {
      stopSessionsPolling();
      stopMessagesPolling();
    });

    return {
      sessions,
      messages,
      selectedSessionId,
      activeSessionName,
      replyText,
      sessionsLoading,
      messagesLoading,
      adminMessageBodyRef,
      selectSession,
      sendAdminReply,
      fetchSessions,
      formatTime
    };
  }
};
</script>

<style scoped>
.support-mgmt-page {
  display: flex;
  flex-direction: column;
  height: 80vh;
}

.page-header {
  margin-bottom: 20px;
}

.chat-dashboard {
  display: grid;
  grid-template-columns: 300px 1fr;
  flex: 1;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
  padding: 0;
  height: 100%;
}

/* Sidebar Styling */
.sessions-sidebar {
  border-right: 1px solid var(--border);
  background: var(--gray-light);
  display: flex;
  flex-direction: column;
}

.sidebar-header {
  padding: 16px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid var(--border);
  background: var(--white);
}

.sidebar-header h3 {
  font-size: 15px;
  margin: 0;
}

.refresh-btn {
  font-size: 11px;
  padding: 4px 8px;
}

.sessions-list {
  flex: 1;
  overflow-y: auto;
}

.empty-list-txt {
  padding: 20px;
  text-align: center;
  font-size: 13px;
  color: var(--gray);
}

.session-item {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border);
  cursor: pointer;
  background: var(--white);
  transition: var(--transition);
}

.session-item:hover {
  background: #fcfcfc;
}

.session-item.active {
  background: #eae4d8;
  border-left: 4px solid var(--primary);
}

.session-info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.session-title-name {
  font-weight: 700;
  font-size: 13px;
  color: var(--dark);
}

.session-badge {
  font-size: 9px;
  font-weight: 700;
  padding: 2px 6px;
  border-radius: 8px;
}

.session-badge.ai {
  background: rgba(241, 196, 15, 0.15);
  color: #d4ac0d;
}

.session-badge.staff {
  background: rgba(46, 204, 113, 0.15);
  color: #27ae60;
}

.session-last-msg {
  font-size: 12px;
  color: var(--gray);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin: 0;
}

/* Chat Panel Styling */
.chat-panel {
  display: flex;
  flex-direction: column;
  background: var(--white);
}

.no-session-selected {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--gray);
  font-size: 14px;
}

.active-chat-container {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.chat-panel-header {
  padding: 16px 24px;
  border-bottom: 1px solid var(--border);
  background: var(--white);
}

.chat-panel-header h3 {
  font-size: 16px;
  margin: 0;
}

.session-id-txt {
  font-size: 10px;
  color: var(--gray);
  margin-top: 2px;
  margin-bottom: 0;
}

.chat-panel-body {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
  background: #fdfbf7;
}

.chat-message-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.msg-bubble-wrapper {
  max-width: 70%;
  display: flex;
  flex-direction: column;
}

.msg-bubble-wrapper.user {
  align-self: flex-start;
  align-items: flex-start;
}

.msg-bubble-wrapper.ai, .msg-bubble-wrapper.staff {
  align-self: flex-end;
  align-items: flex-end;
}

.msg-sender-name {
  font-size: 10px;
  font-weight: 700;
  color: var(--gray);
  margin-bottom: 4px;
}

.msg-bubble {
  padding: 10px 14px;
  border-radius: 14px;
  font-size: 13px;
  line-height: 1.4;
}

.user .msg-bubble {
  background: #eae4d8;
  color: var(--dark);
  border-top-left-radius: 2px;
}

.ai .msg-bubble, .staff .msg-bubble {
  background: var(--dark);
  color: var(--white);
  border-top-right-radius: 2px;
}

.msg-time {
  font-size: 9px;
  color: var(--gray);
  margin-top: 4px;
}

.chat-panel-footer {
  padding: 16px 24px;
  border-top: 1px solid var(--border);
  background: var(--white);
  display: flex;
  gap: 12px;
}

.admin-chat-input {
  flex: 1;
  height: 42px;
}

.admin-chat-send-btn {
  height: 42px;
  padding: 0 24px;
}

.loader-sm {
  text-align: center;
  padding: 20px;
  color: var(--gray);
}
</style>

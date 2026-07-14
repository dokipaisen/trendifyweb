<template>
  <div class="chat-widget-container">
    <!-- Floating Chat Button -->
    <button v-if="!isOpen" @click="toggleChat" class="chat-toggle-btn" aria-label="Mo hop thoai chat">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="chat-toggle-svg"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
    </button>

    <!-- Chat Box Window -->
    <div v-else class="chat-window card">
      <div class="chat-header">
        <div class="chat-header-info">
          <h3>Trendify Support</h3>
          <span class="status-indicator" :class="chatMode.toLowerCase()">
            {{ chatMode === 'AI' ? 'Tự động AI' : 'Nhân viên Live' }}
          </span>
        </div>
        <button @click="toggleChat" class="chat-close-btn">Đóng</button>
      </div>

      <!-- Messages Body -->
      <div class="chat-body" ref="messageBodyRef">
        <div class="chat-message-list">
          <div 
            v-for="msg in messages" 
            :key="msg.id" 
            class="msg-bubble-wrapper"
            :class="msg.sender.toLowerCase()"
          >
            <div class="msg-sender-name">{{ msg.senderName }}</div>
            <div class="msg-bubble">
              <p>{{ msg.message }}</p>
            </div>
            <div class="msg-time">{{ formatTime(msg.createdAt) }}</div>
          </div>
        </div>
      </div>

      <!-- Action Panel -->
      <div class="chat-actions-bar" v-if="chatMode === 'AI'">
        <button @click="connectToStaff" class="btn btn-outline btn-sm staff-connect-btn">
          Chuyển sang gặp nhân viên
        </button>
      </div>

      <!-- Input Footer -->
      <form @submit.prevent="sendChatMessage" class="chat-footer">
        <input 
          type="text" 
          v-model="inputMsg" 
          placeholder="Nhập tin nhắn của bạn..."
          class="form-control chat-input"
          required
        >
        <button type="submit" class="btn btn-primary chat-send-btn">Gửi</button>
      </form>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue';
import { useAuthStore } from '../stores/auth';
import axios from 'axios';

export default {
  name: 'ChatWidget',
  setup() {
    const authStore = useAuthStore();
    const isOpen = ref(false);
    const messages = ref([]);
    const inputMsg = ref('');
    const chatMode = ref('AI'); // 'AI' or 'STAFF'
    const chatSessionId = ref('');
    const messageBodyRef = ref(null);
    let pollTimer = null;

    // Get or generate session ID
    const initSession = () => {
      if (authStore.user) {
        chatSessionId.value = 'user_' + authStore.user.username;
      } else {
        let guestId = localStorage.getItem('guestChatSessionId');
        if (!guestId) {
          guestId = 'guest_' + Math.random().toString(36).substring(2, 11);
          localStorage.setItem('guestChatSessionId', guestId);
        }
        chatSessionId.value = guestId;
      }
    };

    const fetchMessages = async () => {
      if (!chatSessionId.value) return;
      try {
        const response = await axios.get(`/api/chat/messages/${chatSessionId.value}`);
        messages.value = response.data;
        
        // Detect if mode has switched to STAFF based on latest message mode
        if (messages.value.length > 0) {
          const lastMsg = messages.value[messages.value.length - 1];
          if (lastMsg.mode === 'STAFF') {
            chatMode.value = 'STAFF';
          }
        }
        
        scrollToBottom();
      } catch (err) {
        console.error(err);
      }
    };

    const toggleChat = () => {
      isOpen.value = !isOpen.value;
      if (isOpen.value) {
        initSession();
        fetchMessages();
        startPolling();
      } else {
        stopPolling();
      }
    };

    const sendChatMessage = async () => {
      if (!inputMsg.value.trim()) return;

      const userText = inputMsg.value.trim();
      inputMsg.value = '';

      const payload = {
        chatSessionId: chatSessionId.value,
        message: userText,
        senderName: authStore.user ? authStore.user.fullName : 'Khach hang',
        mode: chatMode.value
      };

      try {
        const res = await axios.post('/api/chat/send', payload);
        // Backend returns the generated messages (user and AI if mode is AI)
        if (res.data && res.data.length > 0) {
          messages.value.push(...res.data);
          scrollToBottom();
        } else {
          fetchMessages();
        }
      } catch (err) {
        console.error(err);
      }
    };

    const connectToStaff = async () => {
      try {
        await axios.post(`/api/chat/switch-mode/${chatSessionId.value}`);
        chatMode.value = 'STAFF';
        fetchMessages();
      } catch (err) {
        console.error(err);
      }
    };

    const scrollToBottom = () => {
      nextTick(() => {
        if (messageBodyRef.value) {
          messageBodyRef.value.scrollTop = messageBodyRef.value.scrollHeight;
        }
      });
    };

    const startPolling = () => {
      stopPolling();
      pollTimer = setInterval(fetchMessages, 3000);
    };

    const stopPolling = () => {
      if (pollTimer) {
        clearInterval(pollTimer);
        pollTimer = null;
      }
    };

    const formatTime = (dateStr) => {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
    };

    // Watch for user login changes to update chat session id
    watch(() => authStore.user, () => {
      initSession();
      if (isOpen.value) {
        fetchMessages();
      }
    });

    onMounted(() => {
      initSession();
    });

    onUnmounted(() => {
      stopPolling();
    });

    return {
      isOpen,
      messages,
      inputMsg,
      chatMode,
      messageBodyRef,
      toggleChat,
      sendChatMessage,
      connectToStaff,
      formatTime
    };
  }
};
</script>

<style scoped>
.chat-widget-container {
  position: fixed;
  bottom: 30px;
  right: 30px;
  z-index: 10000;
}

.chat-toggle-btn {
  background: var(--dark);
  color: var(--white);
  border: 1px solid var(--primary);
  border-radius: 50%;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  box-shadow: var(--shadow-md);
  transition: var(--transition);
  padding: 0;
}

.chat-toggle-btn:hover {
  background: var(--primary);
  color: var(--dark);
  transform: translateY(-2px);
}

.chat-toggle-svg {
  width: 24px;
  height: 24px;
  color: var(--primary);
}

.chat-window {
  width: 360px;
  height: 480px;
  display: flex;
  flex-direction: column;
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--border);
  background: var(--white);
  padding: 0;
  overflow: hidden;
}

.chat-header {
  background: var(--dark);
  color: var(--white);
  padding: 16px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 2px solid var(--primary);
}

.chat-header-info h3 {
  font-size: 15px;
  margin-bottom: 2px;
  color: var(--white);
}

.status-indicator {
  font-size: 10px;
  font-weight: 700;
  padding: 2px 6px;
  border-radius: 10px;
  text-transform: uppercase;
}

.status-indicator.ai {
  background: rgba(241, 196, 15, 0.2);
  color: #f1c40f;
}

.status-indicator.staff {
  background: rgba(46, 204, 113, 0.2);
  color: #2ecc71;
}

.chat-close-btn {
  background: transparent;
  border: 1px solid rgba(255,255,255,0.4);
  color: var(--white);
  font-size: 11px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: var(--transition);
}

.chat-close-btn:hover {
  background: rgba(255,255,255,0.1);
}

.chat-body {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: #fdfbf7;
}

.chat-message-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.msg-bubble-wrapper {
  max-width: 80%;
  display: flex;
  flex-direction: column;
}

.msg-bubble-wrapper.user {
  align-self: flex-end;
  align-items: flex-end;
}

.msg-bubble-wrapper.ai, .msg-bubble-wrapper.staff {
  align-self: flex-start;
  align-items: flex-start;
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
  background: var(--dark);
  color: var(--white);
  border-top-right-radius: 2px;
}

.ai .msg-bubble, .staff .msg-bubble {
  background: #eae4d8;
  color: var(--dark);
  border-top-left-radius: 2px;
}

.msg-time {
  font-size: 9px;
  color: var(--gray);
  margin-top: 4px;
}

.chat-actions-bar {
  padding: 10px 20px;
  border-top: 1px solid var(--border);
  background: var(--white);
}

.staff-connect-btn {
  width: 100%;
  font-size: 11px;
  padding: 8px;
}

.chat-footer {
  padding: 12px 20px;
  border-top: 1px solid var(--border);
  background: var(--white);
  display: flex;
  gap: 10px;
}

.chat-input {
  flex: 1;
  font-size: 13px;
  height: 38px;
}

.chat-send-btn {
  height: 38px;
  font-size: 13px;
}
</style>

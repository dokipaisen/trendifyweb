<template>
  <div class="support-page fade-in">
    <div class="container">
      <h1 class="section-title">Trung tâm hỗ trợ khách hàng</h1>

      <div class="support-grid">
        <!-- Contact Information Card -->
        <div class="card support-card">
          <h2>Liên hệ với chúng tôi</h2>
          <p class="desc">Đội ngũ CSKH của chúng tôi luôn sẵn sàng phục vụ bạn 24/7.</p>
          
          <div class="contact-info-list">
            <div class="contact-item">
              <span class="icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
              </span>
              <div>
                <strong>Hotline CSKH</strong>
                <p>1900 8198 (Miễn phí cuộc gọi)</p>
              </div>
            </div>

            <div class="contact-item">
              <span class="icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
              </span>
              <div>
                <strong>Email hỗ trợ</strong>
                <p>support@trendify.com</p>
              </div>
            </div>

            <div class="contact-item">
              <span class="icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
              </span>
              <div>
                <strong>Địa chỉ văn phòng</strong>
                <p>Toà nhà FPT Polytechnic, Trịnh Văn Bô, Nam Từ Liêm, Hà Nội</p>
              </div>
            </div>

            <div class="contact-item">
              <span class="icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
              </span>
              <div>
                <strong>Giờ làm việc</strong>
                <p>Thứ Hai - Chủ Nhật: 08:00 - 22:00</p>
              </div>
            </div>
          </div>
        </div>

        <!-- FAQ Accordion Widget -->
        <div class="card faq-card">
          <h2>Các câu hỏi thường gặp (FAQs)</h2>
          <p class="desc">Giải đáp nhanh các thắc mắc về vận chuyển, đơn hàng và bảo mật.</p>
          
          <div class="faq-accordion">
            <div 
              class="faq-item" 
              v-for="(faq, idx) in faqs" 
              :key="idx"
              :class="{ active: faq.open }"
            >
              <button @click="toggleFaq(faq)" class="faq-question-btn">
                <span>{{ faq.question }}</span>
                <span class="arrow">{{ faq.open ? '▲' : '▼' }}</span>
              </button>
              <div v-show="faq.open" class="faq-answer">
                <p>{{ faq.answer }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';

export default {
  name: 'SupportView',
  setup() {
    const faqs = ref([
      {
        question: 'Tôi có thể đổi trả hàng không? Thủ tục thế nào?',
        answer: 'Chúng tôi hỗ trợ đổi trả hàng miễn phí trong vòng 7 ngày kể từ ngày nhận hàng thành công. Sản phẩm đổi trả phải còn nguyên tem mác, chưa qua giặt là hoặc sử dụng. Hãy liên hệ Hotline 1900 8198 để shipper tới nhận lại hàng đổi trả.',
        open: true
      },
      {
        question: 'Thời gian giao hàng mất bao lâu?',
        answer: 'Thời gian giao hàng nội thành Hà Nội và TP.HCM mất từ 1 - 2 ngày. Các khu vực tỉnh thành khác mất từ 3 - 5 ngày làm việc.',
        open: false
      },
      {
        question: 'Làm thế nào để áp dụng mã giảm giá (voucher)?',
        answer: 'Trong giao diện giỏ hàng (Cart), ở cột bên phải có ô nhập mã giảm giá. Hãy điền mã của bạn và ấn "Áp dụng", hệ thống sẽ tự động trừ chiết khấu nếu đơn hàng thoả mãn yêu cầu giá trị tối thiểu.',
        open: false
      },
      {
        question: 'Trendify hỗ trợ những phương thức thanh toán nào?',
        answer: 'Chúng tôi hỗ trợ phương thức Thanh toán khi nhận hàng (COD) và Chuyển khoản ngân hàng trực tiếp (Bank Transfer) qua quét mã QR tiện lợi.',
        open: false
      }
    ]);

    const toggleFaq = (faq) => {
      faq.open = !faq.open;
    };

    return {
      faqs,
      toggleFaq
    };
  }
};
</script>

<style scoped>
.support-page {
  padding: 60px 0;
}

.support-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
  align-items: start;
}

.support-card h2, .faq-card h2 {
  font-size: 22px;
  margin-bottom: 8px;
}

.desc {
  color: var(--gray);
  font-size: 14px;
  margin-bottom: 30px;
}

.contact-info-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.contact-item {
  display: flex;
  gap: 16px;
}

.contact-item .icon {
  font-size: 28px;
  width: 50px;
  height: 50px;
  background: var(--gray-light);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--border);
}

.contact-item strong {
  font-size: 15px;
  color: var(--dark-light);
  display: block;
  margin-bottom: 2px;
}

.contact-item p {
  font-size: 14px;
  color: var(--gray-dark);
}

/* FAQs Accordion styling */
.faq-accordion {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.faq-item {
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
  transition: var(--transition);
}

.faq-item.active {
  border-color: var(--primary);
  background: #fdfbf7;
}

.faq-question-btn {
  display: flex;
  justify-content: space-between;
  width: 100%;
  background: transparent;
  border: none;
  font-size: 15px;
  font-weight: 600;
  color: var(--dark-light);
  padding: 18px 24px;
  text-align: left;
}

.faq-item.active .faq-question-btn {
  color: var(--primary);
}

.faq-answer {
  padding: 0 24px 18px 24px;
  font-size: 14px;
  color: var(--gray-dark);
  line-height: 1.6;
}

@media (max-width: 768px) {
  .support-grid {
    grid-template-columns: 1fr;
  }
}
</style>

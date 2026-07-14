package com.poly.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DeepSeekService {

    @Value("${deepseek.api-key:}")
    private String apiKey;

    @Value("${deepseek.api-url:https://api.deepseek.com/chat/completions}")
    private String apiUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    private static final String SYSTEM_PROMPT = 
        "Bạn là Trợ lý ảo AI chăm sóc khách hàng của Trendify - Cửa hàng thời trang cao cấp dành cho giới trẻ. " +
        "Hãy trả lời ngắn gọn, lịch sự, chuyên nghiệp. Tuyệt đối KHÔNG sử dụng emoji (biểu tượng cảm xúc) trong câu trả lời. " +
        "Thông tin về cửa hàng Trendify:\n" +
        "- Hỗ trợ đổi trả miễn phí trong 7 ngày đối với hàng còn nguyên tem mác, chưa qua sử dụng. Liên hệ Hotline 1900 8198.\n" +
        "- Giao hàng nội thành Hà Nội và TP.HCM từ 1-2 ngày, các khu vực tỉnh khác từ 3-5 ngày làm việc. Miễn phí vận chuyển cho đơn hàng từ 500k.\n" +
        "- Các dòng sản phẩm: Áo thun, Sơ mi, Quần Jean, Áo khoác, Váy đầm. Giá dao động từ 150k - 800k. Chi tiết xem tại trang Cửa hàng.\n" +
        "- Khách hàng có thể nhập các mã giảm giá: SUMMER26 hoặc TRENDIFY50 tại trang thanh toán.\n" +
        "- Nếu khách hàng muốn gặp trực tiếp nhân viên hỗ trợ hoặc hỏi đáp riêng tư, hãy hướng dẫn họ bấm vào nút 'Gặp nhân viên' trên cửa sổ chat để hệ thống tự động chuyển kết nối.";

    public String generateAIResponse(String userMessage) {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return "DeepSeek API Key chua duoc cau hinh.";
        }

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);

            // Construct payload messages list
            List<Map<String, String>> messages = new ArrayList<>();
            
            Map<String, String> systemMsg = new HashMap<>();
            systemMsg.put("role", "system");
            systemMsg.put("content", SYSTEM_PROMPT);
            messages.add(systemMsg);

            Map<String, String> userMsg = new HashMap<>();
            userMsg.put("role", "user");
            userMsg.put("content", userMessage);
            messages.add(userMsg);

            Map<String, Object> body = new HashMap<>();
            body.put("model", "deepseek-chat");
            body.put("messages", messages);
            body.put("temperature", 0.5);
            body.put("max_tokens", 500);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
            ResponseEntity<Map> response = restTemplate.postForEntity(apiUrl, entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> respBody = response.getBody();
                if (respBody.containsKey("choices")) {
                    List<Map<String, Object>> choices = (List<Map<String, Object>>) respBody.get("choices");
                    if (!choices.isEmpty()) {
                        Map<String, Object> choice = choices.get(0);
                        if (choice.containsKey("message")) {
                            Map<String, String> messageObj = (Map<String, String>) choice.get("message");
                            if (messageObj.containsKey("content")) {
                                return messageObj.get("content");
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error calling DeepSeek API: " + e.getMessage());
            e.printStackTrace();
        }

        return "Xin loi, he thong dang ban. Quy khach vui long thu lai sau hoac an nut 'Gap nhan vien' de duoc ho tro.";
    }
}

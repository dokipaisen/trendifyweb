package com.poly.controller;

import com.poly.entity.ChatMessage;
import com.poly.repository.ChatMessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import com.poly.service.DeepSeekService;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chat")
@CrossOrigin(origins = "http://localhost:5173", allowCredentials = "true")
public class ChatController {

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private DeepSeekService deepSeekService;

    @PostMapping("/send")
    @Transactional
    public ResponseEntity<?> sendMessage(@RequestBody Map<String, String> payload) {
        String chatSessionId = payload.get("chatSessionId");
        String message = payload.get("message");
        String senderName = payload.get("senderName");
        String mode = payload.get("mode"); // 'AI' or 'STAFF'

        if (chatSessionId == null || message == null || message.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Thông tin tin nhắn không hợp lệ."));
        }

        List<ChatMessage> createdMessages = new ArrayList<>();

        // Save User Message
        ChatMessage userMsg = new ChatMessage();
        userMsg.setChatSessionId(chatSessionId);
        userMsg.setSender("USER");
        userMsg.setSenderName(senderName != null ? senderName : "Khách hàng");
        userMsg.setMessage(message);
        userMsg.setMode(mode != null ? mode : "AI");
        ChatMessage savedUserMsg = chatMessageRepository.save(userMsg);
        createdMessages.add(savedUserMsg);

        // If in AI mode, automatically generate responses
        if ("AI".equalsIgnoreCase(userMsg.getMode())) {
            String aiResponse = deepSeekService.generateAIResponse(message);

            ChatMessage aiMsg = new ChatMessage();
            aiMsg.setChatSessionId(chatSessionId);
            aiMsg.setSender("AI");
            aiMsg.setSenderName("Trendify AI");
            aiMsg.setMessage(aiResponse);
            aiMsg.setMode("AI");
            ChatMessage savedAiMsg = chatMessageRepository.save(aiMsg);
            createdMessages.add(savedAiMsg);
        }

        return ResponseEntity.ok(createdMessages);
    }

    @GetMapping("/messages/{sessionId}")
    public ResponseEntity<?> getMessages(@PathVariable("sessionId") String sessionId) {
        List<ChatMessage> list = chatMessageRepository.findByChatSessionIdOrderByCreatedAtAsc(sessionId);
        return ResponseEntity.ok(list);
    }

    @PostMapping("/switch-mode/{sessionId}")
    @Transactional
    public ResponseEntity<?> switchMode(@PathVariable("sessionId") String sessionId) {
        // Save system message indicating queueing for Staff
        ChatMessage sysMsg = new ChatMessage();
        sysMsg.setChatSessionId(sessionId);
        sysMsg.setSender("AI");
        sysMsg.setSenderName("Hệ thống");
        sysMsg.setMessage("Hệ thống đang kết nối bạn với nhân viên tư vấn. Vui lòng chờ trong giây lát.");
        sysMsg.setMode("STAFF");
        chatMessageRepository.save(sysMsg);

        return ResponseEntity.ok(Map.of("success", true, "message", "Switched to STAFF mode."));
    }

    @GetMapping("/admin/sessions")
    public ResponseEntity<?> getAdminSessions() {
        List<ChatMessage> list = chatMessageRepository.findLatestMessagePerSession();
        return ResponseEntity.ok(list);
    }

    @PostMapping("/admin/reply")
    @Transactional
    public ResponseEntity<?> adminReply(@RequestBody Map<String, String> payload) {
        String chatSessionId = payload.get("chatSessionId");
        String message = payload.get("message");
        String senderName = payload.get("senderName");

        if (chatSessionId == null || message == null || message.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Thong tin tin nhan khong hop le."));
        }

        ChatMessage staffMsg = new ChatMessage();
        staffMsg.setChatSessionId(chatSessionId);
        staffMsg.setSender("STAFF");
        staffMsg.setSenderName(senderName != null ? senderName : "Nhan vien ho tro");
        staffMsg.setMessage(message);
        staffMsg.setMode("STAFF");
        
        ChatMessage saved = chatMessageRepository.save(staffMsg);
        return ResponseEntity.ok(saved);
    }
}

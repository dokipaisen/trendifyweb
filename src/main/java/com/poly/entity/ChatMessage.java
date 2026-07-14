package com.poly.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.persistence.*;
import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "chat_messages")
public class ChatMessage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "chat_session_id", nullable = false)
    private String chatSessionId;

    @Column(name = "sender", nullable = false)
    private String sender; // 'USER', 'AI', 'STAFF'

    @Column(name = "sender_name")
    private String senderName;

    @Column(name = "message", nullable = false)
    private String message;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Timestamp createdAt;

    @Column(name = "is_read")
    private Boolean isRead = false;

    @Column(name = "mode")
    private String mode = "AI"; // 'AI', 'STAFF'
}

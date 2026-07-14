package com.poly.repository;

import com.poly.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Integer> {
    
    List<ChatMessage> findByChatSessionIdOrderByCreatedAtAsc(String chatSessionId);

    @Query("SELECT m FROM ChatMessage m WHERE m.id IN (SELECT MAX(c.id) FROM ChatMessage c GROUP BY c.chatSessionId) ORDER BY m.createdAt DESC")
    List<ChatMessage> findLatestMessagePerSession();
}

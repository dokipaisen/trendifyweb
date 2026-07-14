package com.poly.controller;

import com.poly.entity.Order;
import com.poly.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/webhooks")
public class WebhookController {

    @Autowired
    private OrderRepository orderRepository;

    @PostMapping("/apipay")
    @Transactional
    public ResponseEntity<?> receiveAPIPayWebhook(@RequestBody Map<String, Object> payload) {
        System.out.println("Received APIPay Webhook payload: " + payload);

        try {
            // Extract the transfer description/content and amount
            String content = (String) payload.get("content");
            Number amountVal = (Number) payload.get("amount");

            if (content == null || content.trim().isEmpty() || amountVal == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", "Invalid payload structure."));
            }

            Double amount = amountVal.doubleValue();
            
            // Clean content to search for order code (in case other characters are appended)
            String cleanContent = content.trim().toUpperCase();

            // Find matching order in the database
            // Search if cleanContent contains any active orderCode in database, or search exactly
            Optional<Order> orderOpt = orderRepository.findByOrderCode(cleanContent);
            if (!orderOpt.isPresent()) {
                // If not found, try substring match (e.g. if bank appended user notes)
                // Search database for all orders and find one whose order code is inside cleanContent
                orderOpt = orderRepository.findAll().stream()
                        .filter(o -> cleanContent.contains(o.getOrderCode().toUpperCase()))
                        .findFirst();
            }

            if (orderOpt.isPresent()) {
                Order order = orderOpt.get();

                // Validate order status is not already paid to prevent double processing
                if ("PAID".equals(order.getPaymentStatus())) {
                    return ResponseEntity.ok(Map.of("success", true, "message", "Order already marked as PAID."));
                }

                // Verify transferred amount matches order total amount
                if (java.math.BigDecimal.valueOf(amount).compareTo(order.getTotalAmount()) >= 0) {
                    order.setPaymentStatus("PAID");
                    order.setStatus("CONFIRMED");
                    orderRepository.save(order);
                    System.out.println("APIPay Webhook: Order " + order.getOrderCode() + " successfully confirmed and marked PAID.");
                    return ResponseEntity.ok(Map.of("success", true, "message", "Order verified successfully."));
                } else {
                    System.err.println("APIPay Webhook amount mismatch: Transferred " + amount + ", order requires " + order.getTotalAmount());
                    return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", "Transferred amount is insufficient."));
                }
            } else {
                System.err.println("APIPay Webhook: No order matching content '" + cleanContent + "' found.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Order code not recognized."));
            }
        } catch (Exception e) {
            System.err.println("Error processing APIPay Webhook: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("message", "Internal error."));
        }
    }
}

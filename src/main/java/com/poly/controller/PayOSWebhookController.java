package com.poly.controller;

import com.poly.entity.Order;
import com.poly.repository.OrderRepository;
import com.poly.service.PayOSService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
public class PayOSWebhookController {

    @Autowired
    private PayOSService payOSService;

    @Autowired
    private OrderRepository orderRepository;

    @PostMapping("/payos/webhook")
    @Transactional
    public ResponseEntity<?> receivePayOSWebhook(@RequestBody Map<String, Object> payload) {
        System.out.println("Received PayOS Webhook payload: " + payload);

        try {
            // Verify signature
            if (!payOSService.verifyWebhookSignature(payload)) {
                System.err.println("PayOS Webhook error: Signature mismatch.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("success", false, "message", "Signature verification failed."));
            }

            Map<String, Object> data = (Map<String, Object>) payload.get("data");
            if (data == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("success", false, "message", "Missing data object."));
            }

            // PayOS sends orderCode as standard numeric value (Double/Long/Integer) in the JSON
            Number orderCodeVal = (Number) data.get("orderCode");
            Number amountVal = (Number) data.get("amount");

            if (orderCodeVal == null || amountVal == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("success", false, "message", "Invalid orderCode or amount."));
            }

            Long orderCodeLong = orderCodeVal.longValue();
            Double amount = amountVal.doubleValue();

            // Match back to database order code (e.g. "TDF1783976053")
            String orderCodeStr = "TDF" + orderCodeLong;

            Optional<Order> orderOpt = orderRepository.findByOrderCode(orderCodeStr);
            if (orderOpt.isPresent()) {
                Order order = orderOpt.get();

                if ("PAID".equals(order.getPaymentStatus())) {
                    return ResponseEntity.ok(Map.of("success", true, "message", "Order already marked as PAID."));
                }

                // Verify transferred amount matches order total amount
                if (java.math.BigDecimal.valueOf(amount).compareTo(order.getTotalAmount()) >= 0) {
                    order.setPaymentStatus("PAID");
                    order.setStatus("CONFIRMED");
                    orderRepository.save(order);
                    System.out.println("PayOS Webhook: Order " + order.getOrderCode() + " successfully confirmed and marked PAID.");
                    return ResponseEntity.ok(Map.of("success", true, "message", "Order verified successfully."));
                } else {
                    System.err.println("PayOS Webhook amount mismatch: Transferred " + amount + ", order requires " + order.getTotalAmount());
                    return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("success", false, "message", "Transferred amount is insufficient."));
                }
            } else {
                System.err.println("PayOS Webhook: No order matching content '" + orderCodeStr + "' found.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("success", false, "message", "Order code not recognized."));
            }
        } catch (Exception e) {
            System.err.println("Error processing PayOS Webhook: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("success", false, "message", "Internal error."));
        }
    }
}

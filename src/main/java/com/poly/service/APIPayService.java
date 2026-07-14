package com.poly.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
public class APIPayService {

    @Value("${apipay.api-key:}")
    private String apiKey;

    @Value("${apipay.bank-public-id:}")
    private String bankPublicId;

    private final RestTemplate restTemplate = new RestTemplate();

    public String createPaymentRequest(String orderCode, Double amount) {
        if (apiKey == null || apiKey.trim().isEmpty() || bankPublicId == null || bankPublicId.trim().isEmpty()) {
            System.out.println("APIPay API Key or Bank Public ID not configured. Falling back to VietQR.");
            return null;
        }

        try {
            String url = "https://app.apipay.vn/v1/client/payment-requests";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);

            Map<String, Object> body = new HashMap<>();
            body.put("bankPublicId", bankPublicId);
            body.put("amount", amount.intValue());
            body.put("content", orderCode);
            body.put("title", "Trendify Order " + orderCode);
            body.put("redirectUrl", "http://localhost:5173/profile");

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
            ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> respBody = response.getBody();
                if (respBody.containsKey("payUrl")) {
                    return (String) respBody.get("payUrl");
                }
            }
        } catch (Exception e) {
            System.err.println("Error calling APIPay API: " + e.getMessage() + ". Falling back to VietQR.");
        }
        return null;
    }
}

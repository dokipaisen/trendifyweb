package com.poly.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

@Service
public class PayOSService {

    @Value("${payos.client-id:}")
    private String clientId;

    @Value("${payos.api-key:}")
    private String apiKey;

    @Value("${payos.checksum-key:}")
    private String checksumKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public String createPaymentLink(Long orderCode, Double amount) {
        if (clientId == null || clientId.trim().isEmpty() || 
            apiKey == null || apiKey.trim().isEmpty() || 
            checksumKey == null || checksumKey.trim().isEmpty()) {
            System.err.println("PayOS properties are not fully configured.");
            return null;
        }

        try {
            String url = "https://api-merchant.payos.vn/v2/payment-requests";
            String cancelUrl = "http://localhost:5173/profile";
            String returnUrl = "http://localhost:5173/profile";
            String description = "Thanh toan " + orderCode;
            int amountInt = amount.intValue();

            // Construct signature data string sorted alphabetically by keys:
            // amount, cancelUrl, description, orderCode, returnUrl
            String signatureData = "amount=" + amountInt +
                    "&cancelUrl=" + cancelUrl +
                    "&description=" + description +
                    "&orderCode=" + orderCode +
                    "&returnUrl=" + returnUrl;

            String signature = calculateHmacSHA256(signatureData, checksumKey);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("x-client-id", clientId);
            headers.set("x-api-key", apiKey);

            Map<String, Object> body = new HashMap<>();
            body.put("orderCode", orderCode);
            body.put("amount", amountInt);
            body.put("description", description);
            body.put("cancelUrl", cancelUrl);
            body.put("returnUrl", returnUrl);
            body.put("signature", signature);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
            ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> respBody = response.getBody();
                String code = (String) respBody.get("code");
                if ("00".equals(code) && respBody.containsKey("data")) {
                    Map<String, Object> data = (Map<String, Object>) respBody.get("data");
                    if (data.containsKey("checkoutUrl")) {
                        return (String) data.get("checkoutUrl");
                    }
                } else {
                    System.err.println("PayOS API error: " + respBody.get("desc"));
                }
            }
        } catch (Exception e) {
            System.err.println("Error calling PayOS API: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean verifyWebhookSignature(Map<String, Object> payload) {
        if (checksumKey == null || checksumKey.trim().isEmpty()) {
            return false;
        }
        try {
            String signature = (String) payload.get("signature");
            Map<String, Object> data = (Map<String, Object>) payload.get("data");
            if (signature == null || data == null) {
                return false;
            }

            // PayOS signs the data fields sorted alphabetically
            java.util.List<String> sortedKeys = new java.util.ArrayList<>(data.keySet());
            java.util.Collections.sort(sortedKeys);

            StringBuilder dataStr = new StringBuilder();
            for (String key : sortedKeys) {
                Object value = data.get(key);
                if (dataStr.length() > 0) {
                    dataStr.append("&");
                }
                dataStr.append(key).append("=").append(value != null ? value.toString() : "");
            }

            String calculated = calculateHmacSHA256(dataStr.toString(), checksumKey);
            return calculated.equalsIgnoreCase(signature);
        } catch (Exception e) {
            System.err.println("Error verifying webhook signature: " + e.getMessage());
            return false;
        }
    }

    private String calculateHmacSHA256(String data, String key) throws Exception {
        SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(secretKeySpec);
        byte[] rawHmac = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        
        StringBuilder hexString = new StringBuilder();
        for (byte b : rawHmac) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        return hexString.toString();
    }
}

package com.poly.controller;

import com.poly.entity.Promotion;
import com.poly.repository.PromotionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.sql.Timestamp;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/promotions")
public class PromotionController {

    @Autowired
    private PromotionRepository promotionRepository;

    @GetMapping("/check")
    public ResponseEntity<?> checkPromotion(@RequestParam String code) {
        Optional<Promotion> promoOpt = promotionRepository.findByCode(code);
        if (promoOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "Mã giảm giá không tồn tại."));
        }

        Promotion promo = promoOpt.get();
        if (promo.getActive() == null || !promo.getActive()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Mã giảm giá đã ngừng hoạt động."));
        }

        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (promo.getStartDate() != null && now.before(promo.getStartDate())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Mã giảm giá chưa bắt đầu hiệu lực."));
        }
        if (promo.getEndDate() != null && now.after(promo.getEndDate())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Mã giảm giá đã hết hạn sử dụng."));
        }

        return ResponseEntity.ok(promo);
    }
}

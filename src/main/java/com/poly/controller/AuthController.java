package com.poly.controller;

import com.poly.entity.User;
import com.poly.repository.UserRepository;
import com.poly.utils.PasswordUtils;
import jakarta.servlet.http.HttpSession;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Data
    public static class LoginRequest {
        private String username;
        private String password;
    }

    @Data
    public static class PasswordChangeRequest {
        private String oldPassword;
        private String newPassword;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request, HttpSession session) {
        Optional<User> userOpt = userRepository.findByUsername(request.getUsername());
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (PasswordUtils.check(request.getPassword(), user.getPassword())) {
                if ("INACTIVE".equals(user.getStatus())) {
                    return ResponseEntity.status(HttpStatus.FORBIDDEN)
                            .body(Map.of("message", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ."));
                }
                session.setAttribute("currentUser", user);
                return ResponseEntity.ok(user);
            }
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("message", "Tên đăng nhập hoặc mật khẩu không chính xác."));
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        if (userRepository.findByUsername(user.getUsername()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Tên đăng nhập đã tồn tại trong hệ thống."));
        }
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Email đã được sử dụng bởi một tài khoản khác."));
        }

        user.setPassword(PasswordUtils.hash(user.getPassword()));
        user.setRole("CUSTOMER");
        user.setStatus("ACTIVE");
        
        User savedUser = userRepository.save(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedUser);
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpSession session) {
        session.invalidate();
        return ResponseEntity.ok(Map.of("message", "Đăng xuất thành công."));
    }

    @GetMapping("/me")
    public ResponseEntity<?> getMe(HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Chưa đăng nhập."));
        }
        // Fetch fresh copy from database
        Optional<User> freshUser = userRepository.findById(currentUser.getId());
        if (freshUser.isPresent()) {
            session.setAttribute("currentUser", freshUser.get());
            return ResponseEntity.ok(freshUser.get());
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("message", "Người dùng không tồn tại."));
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@RequestBody User userUpdates, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Chưa đăng nhập."));
        }

        Optional<User> userOpt = userRepository.findById(currentUser.getId());
        if (userOpt.isPresent()) {
            User existing = userOpt.get();
            
            // Check email uniqueness if email is modified
            if (!existing.getEmail().equalsIgnoreCase(userUpdates.getEmail())) {
                if (userRepository.findByEmail(userUpdates.getEmail()).isPresent()) {
                    return ResponseEntity.badRequest().body(Map.of("message", "Email này đã được sử dụng bởi người khác."));
                }
            }

            existing.setFullName(userUpdates.getFullName());
            existing.setEmail(userUpdates.getEmail());
            existing.setPhone(userUpdates.getPhone());
            existing.setAddress(userUpdates.getAddress());

            User saved = userRepository.save(existing);
            session.setAttribute("currentUser", saved);
            return ResponseEntity.ok(saved);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy người dùng."));
    }

    @PutMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody PasswordChangeRequest request, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Chưa đăng nhập."));
        }

        Optional<User> userOpt = userRepository.findById(currentUser.getId());
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (!PasswordUtils.check(request.getOldPassword(), user.getPassword())) {
                return ResponseEntity.badRequest().body(Map.of("message", "Mật khẩu cũ không chính xác."));
            }
            user.setPassword(PasswordUtils.hash(request.getNewPassword()));
            userRepository.save(user);
            return ResponseEntity.ok(Map.of("message", "Đổi mật khẩu thành công."));
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Không tìm thấy người dùng."));
    }
}

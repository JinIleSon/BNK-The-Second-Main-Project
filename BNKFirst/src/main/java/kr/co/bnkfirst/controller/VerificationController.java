package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.service.EmailService;
import kr.co.bnkfirst.service.SmsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@RequiredArgsConstructor
@RestController
@RequestMapping("/api/verification")
public class VerificationController {

    private final EmailService emailService;
    private final SmsService smsService;

    private static final long CODE_TTL_SECONDS = 300; // 5분
    private final ConcurrentHashMap<String, CodeEntry> codeStorage = new ConcurrentHashMap<>();

    private record CodeEntry(String code, Instant expiresAt) {}

    private String normalizePhone(String p) {
        return p == null ? null : p.replaceAll("\\D", "");
    }

    // 이메일 인증
    @PostMapping("/email/send")
    public ResponseEntity<Map<String, Object>> sendEmail(@RequestBody Map<String, String> json) {
        String email = json.get("email");
        log.info(">>> VerificationController.sendEmail(), email={}", email);

        try {
            emailService.sendCode(email);
            return ResponseEntity.ok(Map.of("send", true));
        } catch (Exception e) {
            log.error("메일 발송 실패", e);
            return ResponseEntity.status(500).body(Map.of("send", false, "error", e.getMessage()));
        }
    }

    @PostMapping("/email/verify")
    public ResponseEntity<Map<String, Boolean>> verifyEmail(@RequestBody Map<String, String> json) {
        String code = json.get("code");
        boolean matched = emailService.verifyCode(code);
        return ResponseEntity.ok(Map.of("matched", matched));
    }

    // SMS 인증
    @PostMapping(value = "/sms/send", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, Object>> sendSms(@RequestBody Map<String, String> request) {

        String rawPhone = request.get("phoneNumber");
        String phone = normalizePhone(rawPhone);

        if (phone == null || !phone.matches("^01\\d{8,9}$")) {
            return ResponseEntity.badRequest().body(Map.of(
                    "ok", false, "message", "휴대폰 번호 형식이 올바르지 않습니다."
            ));
        }

        try {
            String code = smsService.sendVerificationCode(phone);

            codeStorage.put(phone, new CodeEntry(code, Instant.now().plusSeconds(CODE_TTL_SECONDS)));

            log.debug("SMS 코드 발급: phone={}, code={}", phone, code);

            return ResponseEntity.ok(Map.of("ok", true, "message", "인증번호 전송 완료"));
        } catch (Exception e) {
            log.error("SMS 전송 실패: phone={}, err={}", phone, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "ok", false, "message", "인증번호 전송에 실패했습니다."
            ));
        }
    }

    @PostMapping(value = "/sms/verify", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, Object>> verifySms(@RequestBody Map<String, String> request) {

        String rawPhone = request.get("phoneNumber");
        String inputCode = request.get("code");
        String phone = normalizePhone(rawPhone);

        if (phone == null || inputCode == null || inputCode.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "ok", false, "message", "앗! 정보가 정확하지 않아요. 다시 확인 부탁드려요."
            ));
        }

        CodeEntry entry = codeStorage.get(phone);

        if (entry == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "ok", false, "message", "인증번호를 먼저 요청해 주세요."
            ));
        }

        if (Instant.now().isAfter(entry.expiresAt())) {
            codeStorage.remove(phone);
            return ResponseEntity.status(HttpStatus.GONE).body(Map.of(
                    "ok", false, "message", "인증번호가 만료되었습니다. 다시 전송해 주세요."
            ));
        }

        if (!entry.code().equals(inputCode)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "ok", false, "message", "인증번호가 일치하지 않습니다."
            ));
        }

        codeStorage.remove(phone);

        String token = "sms-" + phone + "-" + Instant.now().toEpochMilli();

        return ResponseEntity.ok(Map.of(
                "ok", true,
                "message", "인증 성공",
                "verificationToken", token
        ));
    }
}

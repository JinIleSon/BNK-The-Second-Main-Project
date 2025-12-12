package kr.co.bnkfirst.service;

import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class QrAuthService {

    // 토큰별 QR 세션을 메모리에 저장 (프로토타입용)
    private final Map<String, QrSession> sessionStore = new ConcurrentHashMap<>();

    /**
     * QR 세션 생성 (PC에서 QR 페이지 열 때 호출)
     */
    public void createSession(String token) {
        QrSession session = new QrSession();
        session.setToken(token);
        session.setStatus(QrStatus.PENDING);          // 처음 상태는 대기
        session.setCreatedAt(LocalDateTime.now());

        sessionStore.put(token, session);
    }

    /**
     * 상태 조회 (PC에서 /auth/qr/status?token=... 호출할 때 사용)
     */
    public String getStatus(String token) {
        QrSession session = sessionStore.get(token);
        if (session == null) {
            return "NOT_FOUND";
        }

        // 예시: 5분 지났으면 만료 처리
        if (session.getCreatedAt().isBefore(LocalDateTime.now().minusMinutes(5))
                && session.getStatus() == QrStatus.PENDING) {
            session.setStatus(QrStatus.EXPIRED);
        }

        return session.getStatus().name();   // PENDING / VERIFIED / EXPIRED
    }

    /**
     * 모바일에서 인증 완료 시 호출 (신분증 인증 끝나면)
     */
    public void verify(String token, String name, String birth, String phone) {
        QrSession session = sessionStore.get(token);
        if (session == null) {
            throw new IllegalArgumentException("유효하지 않은 QR 토큰입니다.");
        }

        session.setStatus(QrStatus.VERIFIED);
        session.setName(name);
        session.setBirth(birth);
        session.setPhone(phone);
        session.setVerifiedAt(LocalDateTime.now());
    }

    // 필요하면 나중에 세션 조회용 메서드도 사용 가능
    public QrSession getSession(String token) {
        return sessionStore.get(token);
    }

    // === 내부용 VO & enum ===

    public static class QrSession {
        private String token;
        private QrStatus status;
        private LocalDateTime createdAt;
        private LocalDateTime verifiedAt;

        private String name;
        private String birth;
        private String phone;

        public String getToken() {
            return token;
        }
        public void setToken(String token) {
            this.token = token;
        }
        public QrStatus getStatus() {
            return status;
        }
        public void setStatus(QrStatus status) {
            this.status = status;
        }
        public LocalDateTime getCreatedAt() {
            return createdAt;
        }
        public void setCreatedAt(LocalDateTime createdAt) {
            this.createdAt = createdAt;
        }
        public LocalDateTime getVerifiedAt() {
            return verifiedAt;
        }
        public void setVerifiedAt(LocalDateTime verifiedAt) {
            this.verifiedAt = verifiedAt;
        }
        public String getName() {
            return name;
        }
        public void setName(String name) {
            this.name = name;
        }
        public String getBirth() {
            return birth;
        }
        public void setBirth(String birth) {
            this.birth = birth;
        }
        public String getPhone() {
            return phone;
        }
        public void setPhone(String phone) {
            this.phone = phone;
        }
    }

    public enum QrStatus {
        PENDING,    // 모바일 인증 대기중
        VERIFIED,   // 모바일에서 인증 완료
        EXPIRED     // 만료됨
    }
}

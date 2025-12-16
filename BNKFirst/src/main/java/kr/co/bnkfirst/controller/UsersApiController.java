// src/main/java/kr/co/bnkfirst/controller/UsersApiController.java
/*
    날짜 : 2025.12.16.
    이름 : 강민철
    내용 : User 관련 API
 */
package kr.co.bnkfirst.controller;

import jakarta.servlet.http.HttpSession;
import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.entity.Users;
import kr.co.bnkfirst.jwt.JwtProvider;
import kr.co.bnkfirst.service.UsersService;
import lombok.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/member")
@RequiredArgsConstructor
@Slf4j
public class UsersApiController {

    private final JwtProvider jwtProvider;
    private final UsersService usersService;

    // ===================== 로그인 =====================

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req,
                                   HttpSession session) {

        log.info("[API] 로그인 시도 mid={}", req.getMid());

        UsersDTO dto = usersService.login(req.getMid(), req.getMpw());
        if (dto == null) {
            // 401 + 에러 메시지
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(new LoginResponse(false, null, 0L,
                            null, "아이디 또는 비밀번호가 올바르지 않습니다."));
        }

        // 최근 접속일자 갱신
        usersService.updateLastAccess(dto.getMid());

        // JWT 생성
        Users user = dto.toEntity();
        String role = dto.getRole();
        String token = jwtProvider.createToken(user, role);

        // 세션 저장 (웹이랑 동일 구조)
        session.setAttribute("jwtToken", token);
        session.setAttribute("loginUser", dto);
        long now = System.currentTimeMillis();
        session.setAttribute("sessionStart", now);
        session.setMaxInactiveInterval(1200); // 20분

        log.info("[API] 로그인 성공 mid={}, token 생성", dto.getMid());

        LoginUserResponse userRes = LoginUserResponse.from(dto);

        LoginResponse body = new LoginResponse(
                true,
                token,
                1200L,
                userRes,
                "로그인 성공"
        );

        return ResponseEntity.ok(body);
    }

    // ===================== 로그아웃 =====================

    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpSession session) {
        Object loginUser = session.getAttribute("loginUser");
        if (loginUser != null) {
            UsersDTO dto = (UsersDTO) loginUser;
            log.info("[API] 사용자 로그아웃 mid={}", dto.getMid());
        }
        session.invalidate();
        return ResponseEntity.ok(new SimpleResult(true, "로그아웃 완료"));
    }

    // ===================== 내 정보 =====================

    @GetMapping("/me")
    public ResponseEntity<?> me(HttpSession session) {
        UsersDTO dto = (UsersDTO) session.getAttribute("loginUser");
        if (dto == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new SimpleResult(false, "로그인이 필요합니다."));
        }
        LoginUserResponse userRes = LoginUserResponse.from(dto);
        long remain = calcRemain(session);

        MeResponse body = new MeResponse(true, userRes, remain);
        return ResponseEntity.ok(body);
    }

    // ===================== 세션 남은 시간 =====================

    @GetMapping("/session/remaining")
    public ResponseEntity<SessionRemainingResponse> remaining(HttpSession session) {
        long remain = calcRemain(session);
        return ResponseEntity.ok(new SessionRemainingResponse(remain));
    }

    // ===================== 세션 연장 =====================

    @PostMapping("/session/extend")
    public ResponseEntity<SessionRemainingResponse> extend(HttpSession session) {
        Object loginUser = session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new SessionRemainingResponse(0L));
        }
        session.setAttribute("sessionStart", System.currentTimeMillis());
        session.setMaxInactiveInterval(1200);
        long remain = calcRemain(session);
        return ResponseEntity.ok(new SessionRemainingResponse(remain));
    }

    private long calcRemain(HttpSession session) {
        Object loginUser = session.getAttribute("loginUser");
        if (loginUser == null) return 0L;

        Long start = (Long) session.getAttribute("sessionStart");
        if (start == null) {
            start = System.currentTimeMillis();
            session.setAttribute("sessionStart", start);
        }
        long passed = (System.currentTimeMillis() - start) / 1000L;
        long remain = 1200L - passed;
        return Math.max(remain, 0L);
    }

    // ===================== 아이디 찾기 =====================

    @PostMapping("/find-id/phone")
    public ResponseEntity<FindIdResponse> findIdByPhone(@RequestBody FindIdPhoneRequest req) {

        String mid = usersService.findIdByPhone(req.getName(), req.getPhone());

        if (mid == null) {
            return ResponseEntity.ok(
                    new FindIdResponse(false, null, "해당 휴대폰 번호로 가입된 아이디가 없습니다.")
            );
        }
        return ResponseEntity.ok(
                new FindIdResponse(true, mid, null)
        );
    }

    @PostMapping("/find-id/email")
    public ResponseEntity<FindIdResponse> findIdByEmail(@RequestBody FindIdEmailRequest req) {

        String mid = usersService.findIdByEmail(req.getName(), req.getEmail());

        if (mid == null) {
            return ResponseEntity.ok(
                    new FindIdResponse(false, null, "해당 정보와 일치하는 아이디가 없습니다.")
            );
        }
        return ResponseEntity.ok(
                new FindIdResponse(true, mid, null)
        );
    }

    // ===================== 비밀번호 찾기(임시비번 발급) =====================

    @PostMapping("/find-pw/phone")
    public ResponseEntity<FindPwResponse> findPwByPhone(@RequestBody FindPwPhoneRequest req) {

        String tempPw = usersService.resetPasswordByPhone(req.getMid(), req.getPhone());

        if (tempPw == null) {
            return ResponseEntity.ok(
                    new FindPwResponse(false, null, "일치하는 회원이 없습니다.")
            );
        }

        return ResponseEntity.ok(
                new FindPwResponse(true, tempPw, null)
        );
    }

    @PostMapping("/find-pw/email")
    public ResponseEntity<FindPwResponse> findPwByEmail(@RequestBody FindPwEmailRequest req) {

        String tempPw = usersService.resetPasswordByEmail(req.getMid(), req.getEmail());

        if (tempPw == null) {
            return ResponseEntity.ok(
                    new FindPwResponse(false, null, "일치하는 회원이 없습니다.")
            );
        }

        return ResponseEntity.ok(
                new FindPwResponse(true, tempPw, null)
        );
    }

    // ===================== 내부 DTO =====================

    @Data
    public static class LoginRequest {
        private String mid;
        private String mpw;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class LoginResponse {
        private boolean ok;
        private String token;
        private long sessionExpiresIn;   // 초 단위 (기본 1200)
        private LoginUserResponse user;
        private String message;
    }

    @Data
    @AllArgsConstructor
    public static class SimpleResult {
        private boolean ok;
        private String message;
    }

    @Data
    @AllArgsConstructor
    public static class MeResponse {
        private boolean ok;
        private LoginUserResponse user;
        private long remainSeconds;
    }

    @Data
    @AllArgsConstructor
    public static class SessionRemainingResponse {
        private long remainSeconds;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LoginUserResponse {
        private int uid;
        private String mid;
        private String mname;
        private String memail;
        private String mphone;
        private String mgrade;
        private String role;

        public static LoginUserResponse from(UsersDTO dto) {
            return LoginUserResponse.builder()
                    .uid(dto.getUid())
                    .mid(dto.getMid())
                    .mname(dto.getMname())
                    .memail(dto.getMemail())
                    .mphone(dto.getMphone())
                    .mgrade(dto.getMgrade())
                    .role(dto.getRole())
                    .build();
        }
    }

    @Data
    public static class FindIdPhoneRequest {
        private String name;
        private String phone;
    }

    @Data
    public static class FindIdEmailRequest {
        private String name;
        private String email;
    }

    @Data
    @AllArgsConstructor
    public static class FindIdResponse {
        private boolean ok;
        private String mid;      // ok=false 인 경우 null
        private String message;  // ok=true 인 경우 null 가능
    }

    @Data
    public static class FindPwPhoneRequest {
        private String mid;
        private String phone;
    }

    @Data
    public static class FindPwEmailRequest {
        private String mid;
        private String email;
    }

    @Data
    @AllArgsConstructor
    public static class FindPwResponse {
        private boolean ok;
        private String tempPw;   // 임시 비밀번호 (ok=false 인 경우 null)
        private String message;  // 에러 메시지
    }
}

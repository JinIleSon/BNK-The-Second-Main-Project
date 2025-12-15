package kr.co.bnkfirst.controller.mobile;

import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.entity.Users;
import kr.co.bnkfirst.jwt.JwtProvider;
import kr.co.bnkfirst.service.UsersService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/mobile/auth")
public class MobileAuthController {

    private final UsersService usersService;
    private final JwtProvider jwtProvider;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {

        String mid = body.get("mid");
        String mpw = body.get("mpw");

        UsersDTO dto = usersService.login(mid, mpw);
        if (dto == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("ok", false, "message", "아이디/비밀번호가 일치하지 않습니다."));
        }

        Users user = dto.toEntity();
        String token = jwtProvider.createToken(user, dto.getRole());

        return ResponseEntity.ok(Map.of(
                "ok", true,
                "token", token,
                "mid", dto.getMid(),
                "role", dto.getRole()
        ));
    }
}
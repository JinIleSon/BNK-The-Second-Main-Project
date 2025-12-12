package kr.co.bnkfirst.dbstock;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DbAuthInitRunner implements ApplicationRunner {

    private final DbAuthService dbAuthService;

    @Override
    public void run(ApplicationArguments args) {
        try {
            dbAuthService.getAccessToken();
        } catch (Exception e) {
            log.error("토큰 발급 실패 — 기존 토큰이 있으면 그걸 계속 사용합니다.");
            if (dbAuthService.getAccessToken() == null) {
                throw e;  // 초기 구동 시 토큰이 없으면 치명적임
            }
        }
    }
}
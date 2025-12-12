package kr.co.bnkfirst.dbstock;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class DbAuthService {

    private final DbAuthProperties props;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    private String accessToken;
    private LocalDateTime expiresAt;

    /** 임시 토큰 */
    private static final String TEMP_TOKEN = "TEMP-DBSEC-TOKEN";

    /** 항상 최신 access token 리턴 */
    public synchronized String getAccessToken() {

        // 기존 토큰이 살아있으면 그대로 사용
        if (accessToken != null && !isExpired()) {
            return accessToken;
        }

        // 만료되었거나 null이면 재발급 시도
        refreshToken();

        return accessToken;
    }

    private boolean isExpired() {
        if (expiresAt == null) return true;
        return expiresAt.isBefore(LocalDateTime.now().plusSeconds(30));
    }

    /** 실제 토큰 발급 + 실패 시 임시 토큰으로 대체 */
    private void refreshToken() {
        System.out.println("🔄 DBSEC 토큰 갱신 시도 중...");

        try {
            String body =
                    "grant_type=client_credentials" +
                            "&appkey=" + URLEncoder.encode(props.getAppkey(), StandardCharsets.UTF_8) +
                            "&appsecretkey=" + URLEncoder.encode(props.getSecret(), StandardCharsets.UTF_8) +
                            "&scope=" + URLEncoder.encode(props.getScope(), StandardCharsets.UTF_8);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(new URI(props.getTokenUrl()))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> response =
                    httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            // HTTP 오류 처리
            if (response.statusCode() != 200) {
                System.err.println("❌ 토큰 발급 실패 (기존 토큰 유지): " + response.body());
                return;
            }

            JsonNode json = objectMapper.readTree(response.body());

            this.accessToken = json.get("access_token").asText();
            long expiresIn = json.get("expires_in").asLong(); // 초 단위
            this.expiresAt = LocalDateTime.now().plusSeconds(expiresIn);

            System.out.println("🎉 DBSEC Token 발급 완료 (expires_in=" + expiresIn + ")");

        } catch (Exception ex) {
            System.err.println("❌ DBSEC Token Refresh Error: " + ex.getMessage());

        }
    }

    /** 임시 토큰 활성화 */
    private void activateTemporaryToken(String reason) {
        System.err.println("⚠️ DBSEC 토큰 발급 실패 → 임시 토큰 사용 (" + reason + ")");
        this.accessToken = TEMP_TOKEN;
        this.expiresAt = LocalDateTime.now().plusYears(10); // 사실상 만료 없음
        System.err.println("🚨 임시 토큰 활성화됨 — 실제 DBSEC API 호출은 동작하지 않음");
    }
}
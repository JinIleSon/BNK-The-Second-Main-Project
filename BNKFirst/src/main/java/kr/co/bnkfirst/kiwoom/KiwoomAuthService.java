package kr.co.bnkfirst.kiwoom;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
public class KiwoomAuthService {

    private final KiwoomAuthProperties props;
    private final ObjectMapper objectMapper = new ObjectMapper();

    private String accessToken;
    private LocalDateTime expiresAt;

    public synchronized String getAccessToken() {
        if (accessToken == null || isExpired()) {
            refreshToken();
        }
        return accessToken;
    }

    private boolean isExpired() {
        if (expiresAt == null) return true;
        return expiresAt.isBefore(LocalDateTime.now().plusSeconds(30)); // 30초 여유
    }

    private void refreshToken() {
        try {
            JsonObject body = new JsonObject();
            body.addProperty("grant_type", "client_credentials");
            body.addProperty("appkey", props.getAppkey());
            body.addProperty("secretkey", props.getSecret());

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(new URI(props.getTokenUrl()))
                    .header("Content-Type", "application/json;charset=UTF-8")
                    .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                    .build();

            HttpClient client = HttpClient.newHttpClient();
            HttpResponse<String> response =
                    client.send(request, HttpResponse.BodyHandlers.ofString());

            JsonObject json = JsonParser.parseString(response.body()).getAsJsonObject();

            // 1) return_code 체크
            int returnCode = json.get("return_code").getAsInt();
            if (returnCode != 0) {
                throw new RuntimeException("Token 발급 실패: " + json.toString());
            }

            // 2) 실제 토큰 필드는 "token"
            this.accessToken = json.get("token").getAsString();

            // 3) 만료일시는 "expires_dt" (yyyyMMddHHmmss)
            String expiresDt = json.get("expires_dt").getAsString(); // 예: 20251119100619
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
            this.expiresAt = LocalDateTime.parse(expiresDt, fmt);

            System.out.println("🎉 Kiwoom Token 갱신 완료: " + expiresDt);

        } catch (Exception ex) {
            throw new RuntimeException("Token Refresh Error", ex);
        }
    }
}
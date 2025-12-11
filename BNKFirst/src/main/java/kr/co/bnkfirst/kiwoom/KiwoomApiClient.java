package kr.co.bnkfirst.kiwoom;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@Component
@RequiredArgsConstructor
public class KiwoomApiClient {

    private final KiwoomAuthService authService;
    private final KiwoomAuthProperties props;

    /**
     * 일단은 응답 raw 문자열을 그대로 리턴하는 버전
     */
    public String getPriceRaw(String code) throws Exception {
        // 일단은 토큰만 잘 나오는지 확인용
        String token = authService.getAccessToken();
        System.out.println("현재 토큰 = " + token);
        return "토큰 OK";
    }

    public JsonObject getPrice(String code) throws Exception {
        String body = getPriceRaw(code);
        JsonObject json = new JsonObject();
        json.addProperty("msg", body);
        return json;
    }
}
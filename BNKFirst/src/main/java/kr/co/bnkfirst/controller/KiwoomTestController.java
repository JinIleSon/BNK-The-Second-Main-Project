package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.kiwoom.HogaWebSocketHandler;
import kr.co.bnkfirst.kiwoom.KiwoomApiClient;
import kr.co.bnkfirst.kiwoom.KiwoomAuthService;
import kr.co.bnkfirst.kiwoom.KiwoomWsClient;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;

@RestController
@RequiredArgsConstructor
public class KiwoomTestController {

    private final KiwoomApiClient kiwoomApiClient;
    private final KiwoomAuthService kiwoomAuthService;
    private final HogaWebSocketHandler hogaWebSocketHandler; // ✅ 추가

    String code = "000660";

    @GetMapping("/kiwoom/ws-test")
    public String wsTest() throws Exception {
        String token = kiwoomAuthService.getAccessToken();

        URI wsUri = new URI("wss://api.kiwoom.com:10000/api/dostk/websocket");
        KiwoomWsClient client = new KiwoomWsClient(wsUri, token, code, msg -> hogaWebSocketHandler.broadcastToBrowsers(msg));
        client.connect();   // 비동기 연결 (키움과 연결 시작)

        return "WebSocket 연결 시도 (로그를 확인해봐)";
    }
}

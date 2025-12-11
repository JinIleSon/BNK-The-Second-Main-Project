package kr.co.bnkfirst.kiwoom;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Component
@RequiredArgsConstructor
public class HogaWebSocketHandler extends TextWebSocketHandler {

    private final KiwoomRealtimeService kiwoomRealtimeService;
    private final Set<WebSocketSession> sessions = ConcurrentHashMap.newKeySet();

    private String currentCode;   // 현재 구독 중인 종목 코드

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        sessions.add(session);
        System.out.println("브라우저 WS 접속: " + session.getId());

        // 쿼리에서 code= 파라미터 추출
        String code = extractCodeFromSession(session);
        System.out.println("브라우저가 요청한 종목코드 = " + code);

        // 첫 접속이면 해당 종목으로 키움 실시간 시작
        if (sessions.size() == 1) {
            currentCode = code;
            kiwoomRealtimeService.start(code, this::broadcastToBrowsers);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        sessions.remove(session);
        System.out.println("브라우저 WS 종료: " + session.getId());

        if (sessions.isEmpty()) {
            // 아무도 안 보면 키움 구독 종료
            kiwoomRealtimeService.stop();
            currentCode = null;
        }
    }

    private String extractCodeFromSession(WebSocketSession session) {
        try {
            if (session.getUri() == null) return "005930"; // 기본값

            String query = session.getUri().getQuery();    // "code=000660" 이런 형태
            if (query == null) return "005930";

            for (String part : query.split("&")) {
                String[] kv = part.split("=");
                if (kv.length == 2 && "code".equals(kv[0])) {
                    return kv[1];
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "005930"; // 예외 나도 기본값
    }

    public void broadcastToBrowsers(String msg) {
        for (WebSocketSession s : sessions) {
            if (s.isOpen()) {
                try {
                    s.sendMessage(new TextMessage(msg));
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}

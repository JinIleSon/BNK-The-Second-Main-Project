package kr.co.bnkfirst.kiwoom;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.util.function.Consumer;

@Service
@RequiredArgsConstructor
public class KiwoomRealtimeService {

    private final KiwoomAuthService kiwoomAuthService;
    private KiwoomWsClient kiwoomClient;

    public synchronized void start(String code, Consumer<String> callback) throws Exception {
        if (kiwoomClient != null && kiwoomClient.isOpen()) {
            return;
        }

        String token = kiwoomAuthService.getAccessToken();
        URI wsUri = new URI("wss://api.kiwoom.com:10000/api/dostk/websocket");

        kiwoomClient = new KiwoomWsClient(
                wsUri,
                token,
                code,
                callback   // ❗️여기만 콜백
        );
        kiwoomClient.connect();
    }
    public synchronized void stop() {
        if (kiwoomClient != null) {
            try { kiwoomClient.close(); } catch (Exception ignored) {}
            kiwoomClient = null;
        }
    }
}

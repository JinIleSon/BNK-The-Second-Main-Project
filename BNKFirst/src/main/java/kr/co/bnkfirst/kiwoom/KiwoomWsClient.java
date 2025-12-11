package kr.co.bnkfirst.kiwoom;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;

import java.net.URI;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.function.Consumer;

public class KiwoomWsClient extends WebSocketClient {

    private final String token;
    private final String code;
    private final Consumer<String> realTimeCallback;
    private ScheduledExecutorService heartbeatScheduler;

    public KiwoomWsClient(URI serverUri, String token,String code, Consumer<String> realTimeCallback) {
        super(serverUri);
        this.token = token;
        this.code = code;
        this.realTimeCallback = realTimeCallback;
    }

    @Override
    public void onMessage(String message) {
        System.out.println("📩 Kiwoom 수신: " + message);
        // 여기서 먼저 trnm 출력해보기
        try {
            JsonObject obj = JsonParser.parseString(message).getAsJsonObject();
            String trnm = obj.get("trnm").getAsString();
            System.out.println(">>> trnm = " + trnm);
        } catch (Exception ignore) {}

        if (realTimeCallback != null) {
            realTimeCallback.accept(message);
        }
    }

    @Override
    public void onOpen(ServerHandshake handshakedata) {
        System.out.println("🔌 Kiwoom WebSocket 연결됨");
        sendLogin();

        // 호가잔량
        sendReg("1", code, "0D");
        // 시세(현재가/등락률)
        sendReg("2", code, "0A");

        startHeartbeat();
    }

    @Override
    public void onClose(int code, String reason, boolean remote) {
        System.out.println("🔌 Kiwoom WebSocket 종료: " + reason);
    }

    @Override
    public void onError(Exception ex) {
        System.out.println("❌ Kiwoom WebSocket 오류: " + ex.getMessage());
    }

    private void sendLogin() {
        JsonObject obj = new JsonObject();
        obj.addProperty("trnm", "LOGIN");
        obj.addProperty("token", token);
        send(obj.toString());
    }

    // 시세(0A) + 우선호가(0C) + 호가잔량(0D) 등록 예시
    private void sendReg(String grpNo, String code, String type) {
        JsonObject root = new JsonObject();
        root.addProperty("trnm", "REG");
        root.addProperty("grp_no", grpNo);
        root.addProperty("refresh", "1");

        JsonObject dataObj = new JsonObject();
        JsonArray items = new JsonArray();
        items.add(code);
        dataObj.add("item", items);

        JsonArray types = new JsonArray();
        types.add(type);
        dataObj.add("type", types);

        JsonArray dataArr = new JsonArray();
        dataArr.add(dataObj);

        root.add("data", dataArr);
        send(root.toString());
        System.out.println("📡 REG 보냄 grp=" + grpNo + ", type=" + type);
    }

    private void startHeartbeat() {
        if (heartbeatScheduler != null && !heartbeatScheduler.isShutdown()) return;

        heartbeatScheduler = Executors.newSingleThreadScheduledExecutor();
        heartbeatScheduler.scheduleAtFixedRate(() -> {
            try {
                if (isOpen()) {
                    sendHeartbeat();
                }
            } catch (Exception e) {
                System.out.println("⚠ heartbeat 전송 실패: " + e.getMessage());
            }
        }, 20, 20, TimeUnit.SECONDS);
    }

    private void stopHeartbeat() {
        if (heartbeatScheduler != null) {
            heartbeatScheduler.shutdownNow();
            heartbeatScheduler = null;
        }
    }

    private void sendHeartbeat() {
        JsonObject obj = new JsonObject();
        obj.addProperty("trnm", "PING"); // 실제 문서에 맞게 수정 필요
        send(obj.toString());
        System.out.println("💓 heartbeat 전송: " + obj);
    }
}

package kr.co.bnkfirst.config;

import kr.co.bnkfirst.kiwoom.HogaWebSocketHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.*;

@Configuration
@EnableWebSocket
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketConfigurer {

    private final HogaWebSocketHandler hogaWebSocketHandler;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(hogaWebSocketHandler, "/ws/hoga")
                .setAllowedOrigins("*");
    }
}

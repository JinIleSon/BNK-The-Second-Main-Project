package kr.co.bnkfirst.kiwoom;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class KiwoomRestTrClient implements KiwoomTrClient {

    private final WebClient webClient;
    private final KiwoomAuthService kiwoomAuthService; // 액세스토큰 가져오는 컴포넌트
    private final ObjectMapper om = new ObjectMapper().enable(SerializationFeature.INDENT_OUTPUT);

    public KiwoomRestTrClient(WebClient.Builder builder,
                              KiwoomAuthService kiwoomAuthService) {
        this.webClient = builder
                .baseUrl("https://api.kiwoom.com")   // ✅ REST 도메인
                .build();
        this.kiwoomAuthService = kiwoomAuthService;
    }


    @Override
    public List<Map<String, String>> call(String trCode,
                                          String blockName,
                                          Map<String, String> input,
                                          int limit) {

        String token = kiwoomAuthService.getAccessToken();

        if ("ka10080".equals(trCode)) {
            // 🔹 분봉 차트
            Map<String, Object> body = webClient.post()
                    .uri("/api/dostk/chart")
                    .header("Content-Type", "application/json;charset=UTF-8")
                    .header("authorization", "Bearer " + token)
                    .header("api-id", trCode)
                    .bodyValue(input)
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<Map<String, Object>>() {})
                    .block();

            return extractMinuteChartRows(body, limit);

        } else if ("ka10032".equals(trCode)) {
            // 🔹 거래대금 상위
            Map<String, Object> body = webClient.post()
                    .uri("/api/dostk/rkinfo")
                    .header("authorization", "Bearer " + token)
                    .header("api-id", trCode)
                    .bodyValue(input)
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<Map<String, Object>>() {})
                    .block();

//            log.info("ka10032={}", body);
            return extractRankRows(body, limit);
        } else if ("ka40004".equals(trCode)) {
            // 🔹 ETF 전체시세
            Map<String, Object> body = webClient.post()
                    .uri("/api/dostk/etf")
                    .header("Content-Type", "application/json;charset=UTF-8")
                    .header("authorization", "Bearer " + token)
                    .header("api-id", trCode)
                    .bodyValue(input)
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<Map<String, Object>>() {})
                    .block();

            return extractEtfRows(body, limit);
        }

        // 그 밖의 TR은 필요에 따라 추가
        throw new IllegalArgumentException("지원하지 않는 trCode: " + trCode);
    }

    // ====== ka10080 전용 파싱 ======
    @SuppressWarnings("unchecked")
    private List<Map<String, String>> extractMinuteChartRows(Map<String, Object> body, int limit) {
        if (body == null) return List.of();

        Object listObj = body.get("stk_min_pole_chart_qry");
        if (!(listObj instanceof List<?> rawList)) return List.of();

        List<Map<String, String>> result = new ArrayList<>();
        for (Object o : rawList) {
            if (!(o instanceof Map<?, ?> m)) continue;

            Map<String, String> row = new HashMap<>();
            m.forEach((k, v) -> row.put(String.valueOf(k),
                    v == null ? null : String.valueOf(v)));
            result.add(row);
            if (result.size() >= limit) break;
        }
        return result;
    }

    // ====== ka10032 전용 파싱 ======
    @SuppressWarnings("unchecked")
    private List<Map<String, String>> extractRankRows(Map<String, Object> body, int limit) {
        if (body == null) return List.of();

        Object arr = body.get("trde_prica_upper");
        if (!(arr instanceof List<?> list)) return List.of();

        List<Map<String, String>> result = new ArrayList<>();
        for (Object o : list) {
            if (!(o instanceof Map<?, ?> m)) continue;

            Map<String, String> row = new HashMap<>();
            m.forEach((k, v) -> row.put(String.valueOf(k),
                    v == null ? null : String.valueOf(v)));
            result.add(row);
            if (result.size() >= limit) break;
        }
        return result;
    }

    // ====== ka40004 전용 파싱 ======
    @SuppressWarnings("unchecked")
    private List<Map<String, String>> extractEtfRows(Map<String, Object> body, int limit) {
        if (body == null) return List.of();

        Object arr = body.get("etfall_mrpr");
        if (!(arr instanceof List<?> list)) return List.of();

        List<Map<String, String>> result = new ArrayList<>();
        for (Object o : list) {
            if (!(o instanceof Map<?, ?> m)) continue;

            Map<String, String> row = new HashMap<>();
            m.forEach((k, v) -> row.put(String.valueOf(k),
                    v == null ? null : String.valueOf(v)));
            result.add(row);
            if (result.size() >= limit) break;
        }
        return result;
    }
}

package kr.co.bnkfirst.dbstock;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@Service
@RequiredArgsConstructor
@Slf4j
public class OverseasStockService {

    private final DbAuthService dbAuthService;   // 토큰 사용 중
    private final ObjectMapper om = new ObjectMapper();
    private final HttpClient http = HttpClient.newHttpClient();

    // ✔ baseUrl 하드코딩
    private static final String ORDERBOOK_URL =
            "https://openapi.dbsec.co.kr:8443/api/v1/quote/overseas-stock/inquiry/orderbook";

    public OverseasOrderbookDto getOrderbook(String code, String marketCode) {

        try {
            // 1) body 형식: { "In" : { ... } }
            ObjectNode body = om.createObjectNode();
            ObjectNode in = body.putObject("In");
            in.put("InputCondMrktDivCode", marketCode);  // "FN"
            in.put("InputIscd1", code);                  // "AAPL" 등

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(ORDERBOOK_URL))
                    .header("content-type", "application/json; charset=utf-8")
                    .header("authorization", "Bearer " + dbAuthService.getAccessToken())
                    .header("cont_yn", "N")
                    .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                    .build();

            HttpResponse<String> response =
                    http.send(request, HttpResponse.BodyHandlers.ofString());
            log.info("DB 해외호가 raw response = {}", response.body());

            JsonNode root = om.readTree(response.body());
            JsonNode out = root.path("Out");

            OverseasOrderbookDto dto = new OverseasOrderbookDto();
            dto.setCode(code);
            dto.setMarket(marketCode);


            // BigDecimal 변환 함수
            java.util.function.Function<JsonNode, BigDecimal> toBig =
                    node -> {
                        if (node == null || node.isMissingNode() || node.isNull()) return null;
                        String txt = node.asText(null);
                        if (txt == null) return null;
                        txt = txt.trim();
                        if (txt.isEmpty() || "-".equals(txt)) return null;
                        return new BigDecimal(txt);
                    };

            // 가격 1~5
            for (int i = 0; i < 5; i++) {
                dto.getAskp()[i] = toBig.apply(out.path("Askp" + (i + 1)));
                dto.getBidp()[i] = toBig.apply(out.path("Bidp" + (i + 1)));
            }

            // 잔량 1~5
            for (int i = 0; i < 5; i++) {
                dto.getAskQty()[i] = out.path("AskpRsqn" + (i + 1)).asLong(0L);
                dto.getBidQty()[i] = out.path("BidpRsqn" + (i + 1)).asLong(0L);
            }

            // ⭐⭐ 여기에 현재가 + 등락률 추가 ⭐⭐
            dto.setPrice(toBig.apply(out.path("StckPrc")));          // 현재가
            dto.setChangeRate(toBig.apply(out.path("PrdyvchgRate"))); // 등락률(%)

            return dto;

        } catch (Exception e) {
            log.error("해외 호가 조회 실패", e);
            // 에러 시에도 프런트가 깨지지 않게 빈 DTO 리턴
            OverseasOrderbookDto empty = new OverseasOrderbookDto();
            empty.setCode(code);
            empty.setMarket(marketCode);
            return empty;
        }
    }

}

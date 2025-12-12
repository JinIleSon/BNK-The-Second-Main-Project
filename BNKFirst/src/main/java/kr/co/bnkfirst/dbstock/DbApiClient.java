package kr.co.bnkfirst.dbstock;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.co.bnkfirst.dbstockrank.DbOverseasPriceDto;
import kr.co.bnkfirst.dbstockrank.OverseasStockInfo;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class DbApiClient {

    private final DbAuthService authService;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    // 이미 있던 callSampleApi() 는 놔두고, 밑에 메서드들 추가

    /** 해외주식 종목코드 조회 (FSTKCODES) */
    public List<OverseasStockInfo> getOverseasStockCodes(String inputDataCodeNyNaAm) throws Exception {

        String token = authService.getAccessToken();

        String bodyJson = String.format(
                "{ \"In\": { \"InputDataCode\":\"%s\" } }",
                inputDataCodeNyNaAm
        );

        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI("https://openapi.dbsec.co.kr:8443/api/v1/quote/overseas-stock/inquiry/stock-ticker"))
                .header("content-type", "application/json;charset=utf-8")
                .header("authorization", "Bearer " + token)
                .header("cont_yn", "N")
                .POST(HttpRequest.BodyPublishers.ofString(bodyJson))
                .build();

        HttpResponse<String> response =
                httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            log.warn("해외종목 조회 실패: {}", response.body());
        }

        JsonNode root = objectMapper.readTree(response.body());
        JsonNode outArray = root.path("Out"); // Body Out 배열

        List<OverseasStockInfo> list = new ArrayList<>();

        for (JsonNode node : outArray) {
            String code = node.path("Iscd").asText();
            String name = node.path("KorIsnm").asText();

            OverseasStockInfo info = new OverseasStockInfo();
            info.setMarketCodeNyNaAm(inputDataCodeNyNaAm);
            info.setMarketCodeFyFnFa(mapNyNaAmToFyFnFa(inputDataCodeNyNaAm));
            info.setCode(code);
            info.setName(name);

            list.add(info);
        }

        return list;
    }

    private String mapNyNaAmToFyFnFa(String in) {
        // 문서 기준: NY → FY, NA → FN, AM → FA 로 매핑
        return switch (in) {
            case "NY" -> "FY";
            case "NA" -> "FN";
            case "AM" -> "FA";
            default -> throw new IllegalArgumentException("Unknown market: " + in);
        };
    }

    /** 멀티현재가 조회 (FSTKMULTIPRICE) – 최대 50개씩 */
    public List<DbOverseasPriceDto> getMultiPrice(List<OverseasStockInfo> stocks) throws Exception {

        if (stocks.isEmpty()) return List.of();

        String token = authService.getAccessToken();

        // 1) Body 생성
        // {
        //   "In": {
        //     "dataCnt":"3",
        //     "InputCondMrktDivCode1":"FN",
        //     "InputIsCd1":"TQQQ",
        //     "InputCondMrktDivCode2":"FN",
        //     "InputIsCd2":"SOXL",
        //     ...
        //   }
        // }

        StringBuilder sb = new StringBuilder();
        sb.append("{\"In\":{");
        sb.append("\"dataCnt\":\"").append(stocks.size()).append("\"");

        for (int i = 0; i < stocks.size(); i++) {
            OverseasStockInfo s = stocks.get(i);
            int idx = i + 1;
            sb.append(",\"InputCondMrktDivCode").append(idx).append("\":\"")
                    .append(s.getMarketCodeFyFnFa()).append("\"");
            sb.append(",\"InputIscd").append(idx).append("\":\"")
                    .append(s.getCode()).append("\"");
        }
        sb.append("}}");

        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI("https://openapi.dbsec.co.kr:8443/api/v1/quote/overseas-stock/inquiry/multiprice"))
                .header("content-type", "application/json;charset=utf-8")
                .header("authorization", "Bearer " + token)
                .header("cont_yn", "N")
                .POST(HttpRequest.BodyPublishers.ofString(sb.toString()))
                .build();

        HttpResponse<String> response =
                httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            log.warn("멀티현재가 조회 실패: {}", response.body());
        }

        JsonNode root = objectMapper.readTree(response.body());
        JsonNode outArray = root.path("Out"); // Body Out 배열

        List<DbOverseasPriceDto> result = new ArrayList<>();

        for (JsonNode node : outArray) {
            DbOverseasPriceDto dto = new DbOverseasPriceDto();
            dto.setCode(node.path("Iscd").asText());
            dto.setName(node.path("KorIsnm").asText());

            dto.setPrice(parseLongSafe(node.path("Prpr").asText()));

            // 등락률 필드명은 문서에서 정확히 보고 맞추기
            String rateStr = node.has("PrdyCtrt")
                    ? node.path("PrdyCtrt").asText()
                    : node.path("PrdyCtr").asText("");
            dto.setChangeRate(parseDoubleSafe(rateStr));

            // 🔴 여기서 거래대금 필드명을 문서에서 확인해서 넣어야 함
            String amountStr = node.path("AcmlTrPbmn").asText(""); // 예시
            dto.setAmount(parseLongSafe(amountStr));

            result.add(dto);
        }

        return result;
    }

    /** 단일 현재가 조회 (FSTKPRICE) – 거래대금까지 정확히 가져오기 */
    public DbOverseasPriceDto getSinglePrice(OverseasStockInfo stock) throws Exception {

        String token = authService.getAccessToken();

        String bodyJson = String.format(
                "{ \"In\": { \"InputCondMrktDivCode\":\"%s\", \"InputIscd1\":\"%s\" } }",
                stock.getMarketCodeFyFnFa(),
                stock.getCode()
        );

        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI("https://openapi.dbsec.co.kr:8443/api/v1/quote/overseas-stock/inquiry/price"))
                .header("content-type", "application/json;charset=utf-8")
                .header("authorization", "Bearer " + token)
                .header("cont_yn", "N")
                .POST(HttpRequest.BodyPublishers.ofString(bodyJson))
                .build();

        HttpResponse<String> response =
                httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            log.warn("해외단일현재가 조회 실패(code={}): {}", response.statusCode(), response.body());
        }

        JsonNode out = objectMapper.readTree(response.body()).path("Out");

        DbOverseasPriceDto dto = new DbOverseasPriceDto();
        dto.setCode(stock.getCode());
        dto.setName(stock.getName());

        dto.setPrice(parseDoubleSafe(out.path("Prpr").asText()));
        dto.setChangeRate(parseDoubleSafe(out.path("PrdyCtrt").asText()));

        // AcmlTrPbmn: 거래대금 (문서 기준) → 소수 포함 가능
        double amt = parseDoubleSafe(out.path("AcmlTrPbmn").asText());
        dto.setAmount((long) amt);   // 만원 단위면 *10000 같은 건 나중에 맞춰도 됨

        return dto;
    }

    private long parseLongSafe(String s) {
        if (s == null) return 0L;
        String cleaned = s.trim().replace(",", "");
        if (cleaned.isEmpty()) return 0L;

        // "10.2700" → BigDecimal(10.2700) → 10 으로 반올림
        BigDecimal bd = new BigDecimal(cleaned);
        bd = bd.setScale(0, RoundingMode.HALF_UP);  // 0자리까지 반올림
        return bd.longValue();
    }

    private double parseDoubleSafe(String s) {
        if (s == null) return 0.0;
        String cleaned = s.trim().replace(",", "");
        if (cleaned.isEmpty()) return 0.0;
        return Double.parseDouble(cleaned);
    }

    // 공통 post 코드
    public JsonNode post(String url, Map<String, Object> body) throws Exception {
        try {
            String token = authService.getAccessToken();
            String bodyJson = objectMapper.writeValueAsString(body);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(new URI("https://openapi.dbsec.co.kr:8443" + url))
                    .header("content-type", "application/json;charset=utf-8")
                    .header("authorization", "Bearer " + token)
                    .header("cont_yn", "N")
                    .POST(HttpRequest.BodyPublishers.ofString(bodyJson))
                    .build();

            HttpResponse<String> response =
                    httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                throw new RuntimeException("DB API Error: " + response.body());
            }

            return objectMapper.readTree(response.body());

        } catch (Exception e) {
            // 여기서 한 번에 런타임 예외로 감싸서 던지기
            throw new RuntimeException("DB API 통신 실패", e);
        }
    }
}

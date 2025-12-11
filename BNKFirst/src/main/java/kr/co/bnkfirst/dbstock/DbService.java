package kr.co.bnkfirst.dbstock;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class DbService {

    private final DbApiClient restClient;
    private final ObjectMapper objectMapper;

    public List<MinuteCandleDTO> getMinuteChart(String code) throws Exception {

        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));

        Map<String, Object> body = Map.of(
                "In", Map.of(
                        "InputOrgAdjPrc", "0",
                        "dataCnt", "400",
                        "InputPwDataIncuYn", "N",
                        "InputHourClsCode", "0",
                        "InputCondMrktDivCode", "FN",
                        "InputIscd1", code,
                        "InputDate1", today,
                        "InputDate2", today,
                        "InputDivXtick", "60"
                )
        );

        // 1) 전체 응답 먼저 받기
        JsonNode root = restClient.post(
                "/api/v1/quote/overseas-stock/chart/min",
                body
        );

        log.info("RAW RESPONSE = {}", root.toPrettyString());

        // 2) 우리가 필요한 Out/Out1 위치로 내려가기
        JsonNode out = root.path("Out");
        log.info("DBSEC min chart Out = {}", out.toPrettyString());

        // 3) 배열이 아니면 그냥 빈 리스트 리턴
        if (!out.isArray()) {
            log.warn("DBSEC Out1 이 배열이 아님: {}", out);
            return List.of();
        }

        // 4) JSON → DTO 리스트 변환
        return objectMapper.convertValue(
                out,
                new TypeReference<List<MinuteCandleDTO>>() {}
        );
    }
}

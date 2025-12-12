package kr.co.bnkfirst.fx;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;

@Service
@RequiredArgsConstructor
@Slf4j
public class FxService {

    private final KoreaEximFxClient fxClient;   // 우리가 이미 만든 Client
    private final ObjectMapper objectMapper;    // 스프링이 자동으로 Bean 등록해줌

    /**
     * 오늘 기준 USD/KRW 환율 가져오기
     */
    public double getUsdKrwRateToday() {
        return getUsdKrwRate(LocalDate.now());
    }

    /**
     * 특정 날짜 기준 USD/KRW 환율
     * - 토/일이면 직전 금요일로 보정
     * - 그래도 데이터가 없으면 하루씩 과거로 최대 7영업일 뒤로 가면서 탐색
     */
    public double getUsdKrwRate(LocalDate date) {

        // 1) 우선 요청 날짜를 영업일 기준으로 맞추기 (토/일 → 직전 금요일)
        LocalDate current = adjustToBusinessDay(date);

        // 2) 최대 7번까지 하루씩 뒤로 가면서 환율 탐색
        for (int i = 0; i < 7; i++) {
            String json = fxClient.getRatesRaw(current);

            try {
                JsonNode arr = objectMapper.readTree(json);

                if (arr.isArray() && arr.size() > 0) {
                    // 🔥 이 날짜에는 데이터가 있음 → 여기서 USD 환율 찾아서 반환
                    for (JsonNode node : arr) {
                        String curUnit = node.path("cur_unit").asText(); // "USD" 등
                        if ("USD".equals(curUnit)) {
                            String dealBasR = node.path("deal_bas_r").asText(); // "1,461.99" 형식
                            dealBasR = dealBasR.replace(",", "");
                            double rate = Double.parseDouble(dealBasR);

                            log.info("[FxService] FX found. baseDate={}, USD/KRW={}",
                                    current, rate);
                            return rate;
                        }
                    }

                    // 여기까지 왔다는 건 배열은 있는데 USD가 없는 경우
                    log.warn("[FxService] FX data exists but USD not found. date={}", current);
                } else {
                    // 이 날짜에는 배열 자체가 비어 있음
                    log.warn("[FxService] no FX data for {} (size=0)", current);
                }

            } catch (IOException e) {
                throw new RuntimeException("환율 응답(JSON) 파싱 실패. date=" + current, e);
            }

            // 3) 여기까지 왔다는 건 환율을 못 찾았다는 것 → 하루 뒤로(back) 이동
            LocalDate prevDay = current.minusDays(1);
            current = adjustToBusinessDay(prevDay);
            log.info("[FxService] try previous business day. nextDate={}", current);
        }

        // 7영업일 동안 아무 데이터도 못 찾은 경우
        throw new IllegalStateException("최근 7영업일 동안 환율 데이터를 찾지 못했습니다. 기준일=" + date);
    }

    /**
     * 토/일이면 직전 금요일로 돌리는 간단 보정
     */
    private LocalDate adjustToBusinessDay(LocalDate date) {
        DayOfWeek dow = date.getDayOfWeek();
        if (dow == DayOfWeek.SATURDAY) {
            return date.minusDays(1);
        } else if (dow == DayOfWeek.SUNDAY) {
            return date.minusDays(2);
        }
        return date;
    }
}

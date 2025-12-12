package kr.co.bnkfirst.kiwoom;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class KiwoomHistoryClient {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HHmm");

    // 🔹 실제로 TR을 쏘는 공용 클라이언트 (너네 프로젝트 이름에 맞춰 바꿔)
    private final KiwoomTrClient kiwoomTrClient;

    /**
     * 코드별 과거 1분봉을 limit 개 가져온다 (최대 300개 정도).
     */
    public List<HistoricalCandle> fetchMinuteCandles(String code, int limit) {

        // 1) TR 입력값 세팅 (opt10080 = 주식분봉차트)
        Map<String, String> in = new HashMap<>();
        in.put("종목코드", code);
        in.put("틱범위", "1");           // 1분봉
        in.put("기준일자", LocalDate.now(KST).format(DATE_FMT));  // 오늘 기준
        in.put("수정주가구분", "1");     // 수정주가

        // 2) TR 호출 (block name 은 네 GW 구현에 맞게)
        //    rows 는 최신봉이 0번 인덱스로 온다고 가정
        List<Map<String, String>> rows =
                kiwoomTrClient.call("opt10080", "주식분봉차트", in, limit);

        if (rows == null || rows.isEmpty()) {
            return Collections.emptyList();
        }

        List<HistoricalCandle> result = new ArrayList<>();

        for (Map<String, String> row : rows) {
            try {
                String dateStr = row.get("일자");      // YYYYMMDD
                String timeStr = row.get("체결시간");  // HHMM

                if (dateStr == null || timeStr == null) continue;

                LocalDate date = LocalDate.parse(dateStr.trim(), DATE_FMT);
                LocalTime time = LocalTime.parse(timeStr.trim(), TIME_FMT);
                LocalDateTime ldt = LocalDateTime.of(date, time);

                long open  = parsePrice(row.get("시가"));
                long high  = parsePrice(row.get("고가"));
                long low   = parsePrice(row.get("저가"));
                long close = parsePrice(row.get("현재가"));

                result.add(new HistoricalCandle(ldt, open, high, low, close));
            } catch (Exception e) {
                // 한 줄 파싱 실패해도 나머지는 계속
                e.printStackTrace();
            }
        }

        // TR 은 최신→과거 순서로 올 확률이 높으니까
        // 차트는 과거→최신 순으로 보기 좋게 정렬
        result.sort(Comparator.comparing(HistoricalCandle::getDateTime));

        // 혹시 300개보다 많이 왔으면 뒤에서 잘라서 반환
        if (result.size() > limit) {
            return result.subList(result.size() - limit, result.size());
        }
        return result;
    }

    // " -97850" → 97850
    private long parsePrice(String raw) {
        if (raw == null) return 0L;
        String cleaned = raw.replace(" ", "");
        long v = Long.parseLong(cleaned);
        return Math.abs(v);
    }
}

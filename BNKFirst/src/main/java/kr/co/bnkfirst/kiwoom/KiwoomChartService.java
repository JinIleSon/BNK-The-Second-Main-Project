// src/main/java/kr/co/bnkfirst/kiwoom/KiwoomChartService.java
package kr.co.bnkfirst.kiwoom;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class KiwoomChartService {

    private final KiwoomTrClient trClient;

    // code+interval 캐시
    private final Map<String, List<CandleDTO>> cache = new ConcurrentHashMap<>();

    public void ensureHistoryLoaded(String code, String interval, int limit) {
        String key = cacheKey(code, interval);
        List<CandleDTO> existing = cache.get(key);
        if (existing != null && !existing.isEmpty()) return;

        List<CandleDTO> candles = loadHistoryFromKiwoom(code, interval, limit);
        cache.put(key, candles);
    }

    public List<CandleDTO> getCandles(String code, String interval) {
        return cache.getOrDefault(cacheKey(code, interval), List.of());
    }

    private String cacheKey(String code, String interval) {
        return code + "_" + interval;
    }

    private List<CandleDTO> loadHistoryFromKiwoom(String code,
                                                  String interval,
                                                  int limit) {

        // ka10080 : 분봉 차트
        String trCode = "ka10080";

        Map<String, String> input = new HashMap<>();
        input.put("stk_cd", code);                 // 종목코드
        input.put("tic_scope", toTicScope(interval)); // "1m" -> "1"
        input.put("upd_stkpc_tp", "1");           // 수정주가

        List<Map<String, String>> rows =
                trClient.call(trCode, "stk_min_pole_chart_qry", input, limit);

        List<CandleDTO> list = new ArrayList<>();
        for (Map<String, String> r : rows) {
            CandleDTO c = toCandleDTO(r);
            if (c != null) list.add(c);
        }

        // 오래된 봉부터 정렬
        list.sort(Comparator.comparingLong(CandleDTO::getTime));
        return list;
    }

    private String toTicScope(String interval) {
        // "1m", "3m", ... -> "1", "3"
        if (interval.endsWith("m")) {
            return interval.substring(0, interval.length() - 1);
        }
        throw new IllegalArgumentException("지원하지 않는 interval: " + interval);
    }

    private CandleDTO toCandleDTO(Map<String, String> row) {
        try {
            String cntrTm = row.get("cntr_tm");
            long epochSec = parseCntrTimeToEpoch(cntrTm);

            long open  = parseKiwoomAbsSafe(row.get("open_pric"));
            long high  = parseKiwoomAbsSafe(row.get("high_pric"));
            long low   = parseKiwoomAbsSafe(row.get("low_pric"));
            long close = parseKiwoomAbsSafe(row.get("cur_prc"));

            // 모든 값이 0이면 이 봉은 무효일 수도 있으니 스킵
            if (open == 0 && high == 0 && low == 0 && close == 0) {
                log.warn("toCandleDTO: 빈 캔들 스킵 row={}", row);
                return null;
            }

            return new CandleDTO(epochSec, open, high, low, close);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private long parseKiwoomAbsSafe(String raw) {
        if (raw == null) return 0L;

        String s = raw.trim();
        if (s.isEmpty() || "-".equals(s)) return 0L;

        s = s.replace("+", "").replace("-", "");

        try {
            return Long.parseLong(s);
        } catch (NumberFormatException e) {
            log.warn("parseKiwoomAbsSafe 숫자 변환 실패 raw='{}'", raw);
            return 0L;
        }
    }

    private long parseCntrTimeToEpoch(String cntrTm) {
        if (cntrTm == null || cntrTm.length() != 14) return 0L;
        int year  = Integer.parseInt(cntrTm.substring(0, 4));
        int month = Integer.parseInt(cntrTm.substring(4, 6));
        int day   = Integer.parseInt(cntrTm.substring(6, 8));
        int hour  = Integer.parseInt(cntrTm.substring(8, 10));
        int min   = Integer.parseInt(cntrTm.substring(10, 12));
        int sec   = Integer.parseInt(cntrTm.substring(12, 14));

        LocalDateTime dt = LocalDateTime.of(year, month, day, hour, min, sec);
        return dt.toEpochSecond(ZoneOffset.UTC); // 한국 시간
    }
}
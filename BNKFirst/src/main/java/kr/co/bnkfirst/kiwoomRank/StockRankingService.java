package kr.co.bnkfirst.kiwoomRank;

import jakarta.annotation.PostConstruct;
import kr.co.bnkfirst.dbstockrank.OverseasStockRankingService;
import kr.co.bnkfirst.kiwoom.KiwoomRateLimitException;
import kr.co.bnkfirst.kiwoom.KiwoomTrClient;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
@Getter
@Slf4j
public class StockRankingService {

    private final KiwoomTrClient trClient;
    private final OverseasStockRankingService overseasStockRankingService;

    // 🔥 최신 랭크 데이터를 저장할 캐시
    private volatile List<StockRankDTO> cachedRanks = new ArrayList<>();

    /**
     * 서버 시작 시 최초 1회 실행
     */
    @PostConstruct
    public void init() {
        refreshRanking();  // 첫 로딩
    }

    /**
     * 🔥 1.5초마다 자동 실행
     */
    @Scheduled(fixedRate = 1500)
    public void refreshRanking() {
        try {
            List<StockRankDTO> list = fetchRanking(100); // 원하는 TOP N
            cachedRanks = list; // 원자적 교체
        } catch (KiwoomRateLimitException e) {
            // 🔥 조용히 무시하고 캐시 유지
            log.warn("Kiwoom 요청 제한(429) — 이번 회차는 기존 캐시 유지");
        } catch (Exception e) {
            log.error("국내 랭킹 갱신 실패", e);
        }
    }

    /**
     * 외부에서 조회할 때는 캐시된 값을 반환
     */
    public List<StockRankDTO> getCachedRanks() {
        return cachedRanks;
    }
    /**
     * 실제 TR 호출 메서드
     */
    public List<StockRankDTO> fetchRanking(int limit) {
        Map<String, String> input = new HashMap<>();
        input.put("mrkt_tp", "001");      // 코스피
        input.put("mang_stk_incls", "1");
        input.put("stex_tp", "3");

        List<Map<String, String>> rows =
                trClient.call("ka10032", "trde_prica_upper", input, limit);

        List<StockRankDTO> list = new ArrayList<>();

        for (Map<String, String> row : rows) {
            StockRankDTO dto = toDto(row);
            if (dto != null) {
                list.add(dto);
                if (list.size() >= limit) break;
            }
        }

        list.sort(Comparator.comparingInt(StockRankDTO::getRank));
        return list;
    }
    /**
     * 거래대금 상위 N개
     */
    public List<StockRankDTO> getTopByTradingValue(int limit) {
        // ka10032 입력값(시장구분 등)은 문서보고 필요 시 추가
        Map<String, String> input = new HashMap<>();
        // 예시: 코스피만 보고 싶다면 이런 식으로
        // input.put("mkt_gb", "1");
        input.put("mrkt_tp", "001");      // 001: 코스피 (문서 확인해서 맞추기)
        input.put("mang_stk_incls", "1"); // 1: 관리종목 포함 여부
        input.put("stex_tp", "3");        // 3: 정규시장? (역시 문서 기준)

        List<Map<String, String>> rows =
                trClient.call("ka10032", "trde_prica_upper", input, limit);

        System.out.println("### ka10032 rows size = " + rows.size());
        System.out.println("### ka10032 first row = " + (rows.isEmpty()? "empty" : rows.get(0)));

        List<StockRankDTO> list = new ArrayList<>();

        for (Map<String, String> row : rows) {
            StockRankDTO dto = toDto(row);
            if (dto != null) {
                list.add(dto);
                if (list.size() >= limit) break;
            }
        }

        // now_rank 기준으로 다시 정렬(혹시 섞여있을 수 있으니)
        list.sort(Comparator.comparingInt(StockRankDTO::getRank));

        return list;
    }

    private StockRankDTO toDto(Map<String, String> row) {
        try {
            int rank      = Integer.parseInt(row.getOrDefault("now_rank", "0"));
            String code   = row.get("stk_cd");
            String name   = row.get("stk_nm");

            long price    = parseAbs(row.get("cur_prc"));      // 현재가
            double rate   = Double.parseDouble(row.getOrDefault("flu_rt", "0"));
            long amount   = Long.parseLong(row.getOrDefault("trde_prica", "0"));

            return StockRankDTO.builder()
                    .rank(rank)
                    .code(code)
                    .name(name)
                    .price(price)
                    .changeRate(rate)
                    .amount(amount)
                    .build();

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private long parseAbs(String s) {
        if (s == null) return 0L;
        String cleaned = s.trim().replace(",", "");
        long v = Long.parseLong(cleaned);
        return Math.abs(v); // "-152000" → 152000
    }

    public List<StockRankDTO> getTopByTradingValueAbroad(int limit) {
        List<StockRankDTO> cached = overseasStockRankingService.getCachedRanks();
        if (cached == null || cached.isEmpty()) {
            return Collections.emptyList();
        }
        if (cached.size() <= limit) {
            return cached;
        }
        return cached.subList(0, limit);
    }
}
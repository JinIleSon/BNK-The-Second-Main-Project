// src/main/java/kr/co/bnkfirst/controller/StockApiController.java
/*
    날짜 : 2025.12.17.
    이름 : 강민철
    내용 : StockController API
 */
package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.fx.FxService;
import kr.co.bnkfirst.kiwoomRank.StockRankDTO;
import kr.co.bnkfirst.kiwoomRank.StockRankingService;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/stock")
@RequiredArgsConstructor
@Slf4j
public class StockApiController {

    private final StockRankingService rankingService;
    private final FxService fxService;

    /**
     * 국내 주식 메인용 데이터
     * - 랭킹 TOP N
     * - 오늘 기준 USD/KRW 환율
     *
     * GET /api/stock/main?limit=100
     */
    @GetMapping("/main")
    public StockMainResponse getDomesticMain(
            @RequestParam(name = "limit", defaultValue = "100") int limit
    ) {
        List<StockRankDTO> ranks = rankingService.getTopByTradingValue(limit);
        double usdKrw = fxService.getUsdKrwRate(LocalDate.now());

        log.info("[API] /api/stock/main ranks={}, usdKrw={}", ranks.size(), usdKrw);

        return new StockMainResponse(ranks, usdKrw);
    }

    /**
     * 해외 주식 메인용 데이터
     * - 해외 랭킹 TOP N
     * - 오늘 기준 USD/KRW 환율
     *
     * GET /api/stock/mainAbroad?limit=100
     */
    @GetMapping("/mainAbroad")
    public StockMainResponse getAbroadMain(
            @RequestParam(name = "limit", defaultValue = "100") int limit
    ) {
        List<StockRankDTO> ranks = rankingService.getTopByTradingValueAbroad(limit);
        double usdKrw = fxService.getUsdKrwRate(LocalDate.now());

        log.info("[API] /api/stock/mainAbroad ranks={}, usdKrw={}", ranks.size(), usdKrw);

        return new StockMainResponse(ranks, usdKrw);
    }

    /**
     * 국내 랭킹만 단독으로 조회
     *
     * GET /api/stock/ranks?limit=100
     */
    @GetMapping("/ranks")
    public List<StockRankDTO> getDomesticRanks(
            @RequestParam(name = "limit", defaultValue = "100") int limit
    ) {
        List<StockRankDTO> ranks = rankingService.getTopByTradingValue(limit);
        log.info("[API] /api/stock/ranks size={}", ranks.size());
        return ranks;
    }

    /**
     * 해외 랭킹만 단독으로 조회
     *
     * GET /api/stock/ranks/abroad?limit=100
     */
    @GetMapping("/ranks/abroad")
    public List<StockRankDTO> getAbroadRanks(
            @RequestParam(name = "limit", defaultValue = "100") int limit
    ) {
        List<StockRankDTO> ranks = rankingService.getTopByTradingValueAbroad(limit);
        log.info("[API] /api/stock/ranks/abroad size={}", ranks.size());
        return ranks;
    }

    /**
     * USD/KRW 환율만 단독으로 조회
     *
     * GET /api/stock/usd-krw         → 오늘 기준
     * GET /api/stock/usd-krw?date=2025-12-17
     */
    @GetMapping("/usd-krw")
    public FxResponse getUsdKrw(
            @RequestParam(name = "date", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        LocalDate target = (date != null) ? date : LocalDate.now();
        double usdKrw = fxService.getUsdKrwRate(target);
        log.info("[API] /api/stock/usd-krw date={}, usdKrw={}", target, usdKrw);
        return new FxResponse(target, usdKrw);
    }

    // ------------ 응답 DTO들 ------------

    @Data
    @AllArgsConstructor
    public static class StockMainResponse {
        private List<StockRankDTO> ranks;
        private double usdKrw;
    }

    @Data
    @AllArgsConstructor
    public static class FxResponse {
        private LocalDate date;
        private double usdKrw;
    }
}

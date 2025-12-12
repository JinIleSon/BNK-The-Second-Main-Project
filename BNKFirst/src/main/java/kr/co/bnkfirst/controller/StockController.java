package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.fx.FxService;
import kr.co.bnkfirst.kiwoomRank.StockRankingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cglib.core.Local;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;

@Controller
@RequiredArgsConstructor
@Slf4j
public class StockController {

    private final StockRankingService rankingService;
    private final FxService fxService;//세현

    @GetMapping("/stock/main")
    public String mainPage(Model model) {

        model.addAttribute("ranks",
                rankingService.getTopByTradingValue(100));
        log.info("rank = {}", rankingService.getTopByTradingValue(100));

        double usdKrw = fxService.getUsdKrwRate(LocalDate.now());//세현
        model.addAttribute("usdKrw", usdKrw);//세현

        return "stock/stock_main";
    }

    @GetMapping("/stock/mainAbroad")
    public String mainAbroadPage(Model model) {

        var ranks = rankingService.getTopByTradingValueAbroad(100);
        model.addAttribute("ranks", ranks);
        log.info("overseas ranks size = {}", ranks.size());

        /*
        날짜: 2025-11-25
        작업자: 전세현
        내용: 오늘 기준 USD/KRW 환율
         */
        double usdKrw = fxService.getUsdKrwRate(LocalDate.now());
        model.addAttribute("usdKrw", usdKrw);
        log.info("usdKrw (abroad) = {}", usdKrw);

        return "stock/stock_mainAbroad";
    }

    @GetMapping("/stock/order")
    public String stockOrder(@RequestParam("code") String code,
                             @RequestParam(value = "name", required = false) String name,
                             Model model) {

        // name을 안 넘겨줬으면 code를 그냥 이름처럼 보여주도록 임시 처리
        String stockName = (name != null && !name.isBlank()) ? name : code;

        model.addAttribute("code", code);
        model.addAttribute("stockName", stockName);

        return "stock/stock_order";   // 템플릿 경로에 맞게
    }

    @GetMapping("/stock/orderAbroad")
    public String stockOrderAbroad(@RequestParam("code") String code,
                             @RequestParam(value = "name", required = false) String name,
                             Model model) {
        var ranks = rankingService.getTopByTradingValueAbroad(100);
        model.addAttribute("ranks", ranks);

        // name을 안 넘겨줬으면 code를 그냥 이름처럼 보여주도록 임시 처리
        String stockName = (name != null && !name.isBlank()) ? name : code;

        model.addAttribute("code", code);
        model.addAttribute("stockName", stockName);

        // 'FN'은 나스닥
        model.addAttribute("marketCode", "FN");

        return "stock/stock_orderAbroad";   // 템플릿 경로에 맞게
    }
}

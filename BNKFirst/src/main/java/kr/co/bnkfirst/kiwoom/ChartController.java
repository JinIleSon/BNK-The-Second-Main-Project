package kr.co.bnkfirst.kiwoom;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/chart")
@RequiredArgsConstructor
public class ChartController {

    private final KiwoomChartService chartService;


    @GetMapping("/{code}")
    public List<CandleDTO> getChart(
            @PathVariable String code,
            @RequestParam(name = "interval", defaultValue = "1m") String interval
    ) {
        // ✅ 이 종목/인터벌의 과거 데이터가 없으면 먼저 채워 넣기
        chartService.ensureHistoryLoaded(code, interval, 300); // 최근 300개 분봉 정도

        // 그리고 지금까지 누적된(과거 + 실시간) 봉 리턴
        return chartService.getCandles(code, interval);
    }


}


package kr.co.bnkfirst.kiwoomRank;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class StockRankingController {

    private final StockRankingService service;

    @GetMapping("/api/ranks")
    public List<StockRankDTO> getRanks() {
        return service.getCachedRanks();  // 2초마다 갱신되는 최신 캐시 반환
    }
}
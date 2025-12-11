package kr.co.bnkfirst.dbstockrank;


import kr.co.bnkfirst.kiwoomRank.StockRankDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class OverseasRankRestController {

    private final OverseasStockRankingService overseasService;

    @GetMapping("/api/overseas-ranks")
    public List<StockRankDTO> getOverseasRanks() {
        return overseasService.getCachedRanks();
    }
}
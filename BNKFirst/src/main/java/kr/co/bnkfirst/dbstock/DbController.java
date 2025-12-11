package kr.co.bnkfirst.dbstock;

import kr.co.bnkfirst.dbstockrank.DbOverseasPriceDto;
import kr.co.bnkfirst.dbstockrank.OverseasStockInfo;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@AllArgsConstructor
@Slf4j
public class DbController {

    private final DbService dbService;
    private final DbApiClient dbApiClient;
    private final OverseasStockService overseasStockService;

    @GetMapping("/api/chartAbroad")
    public List<MinuteCandleDTO> getMinuteChart(@RequestParam("code") String code) throws Exception {
        List<MinuteCandleDTO> rows = dbService.getMinuteChart(code);
        log.info("chartAbroad rows size = {}", rows.size());
        return rows;
    }

    @GetMapping("/api/overseas/price")
    public OverseasQuoteViewDto getOverseasPrice(
            @RequestParam String market,
            @RequestParam String code,
            @RequestParam(required = false) String name
    ) throws Exception {

        OverseasStockInfo info = new OverseasStockInfo();
        info.setMarketCodeFyFnFa(market);
        info.setCode(code);
        info.setName(name != null ? name : "");

        DbOverseasPriceDto origin = dbApiClient.getSinglePrice(info);

        // 변환
        OverseasQuoteViewDto dto = new OverseasQuoteViewDto();
        dto.setCode(origin.getCode());
        dto.setName(origin.getName());
        dto.setPrice(origin.getPrice());
        dto.setChangeRate(origin.getChangeRate());
        dto.setAmount(origin.getAmount());
        dto.setBid(origin.getBid());
        dto.setAsk(origin.getAsk());

        // 상승/하락 sign
        double r = origin.getChangeRate();
        if (r > 0) {
            dto.setSign("+");
            dto.setColor("red");
        } else if (r < 0) {
            dto.setSign("-");
            dto.setColor("blue");
        } else {
            dto.setSign("");
            dto.setColor("gray");
        }

        return dto;
    }

    @GetMapping("/api/overseas/orderbook")
    public OverseasOrderbookDto getOrderbook(
            @RequestParam String code,
            @RequestParam String market) {

        return overseasStockService.getOrderbook(code, market);
    }
}

// src/main/java/kr/co/bnkfirst/kiwoomETF/EtfApiController.java
package kr.co.bnkfirst.kiwoomETF;

import kr.co.bnkfirst.dto.product.PcontractDTO;
import kr.co.bnkfirst.fx.FxService;
import kr.co.bnkfirst.service.StockService;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/api/etf")
@RequiredArgsConstructor
public class EtfApiController {

    private final EtfService etfService;
    private final FxService fxService;
    private final StockService stockService;

    // ---------------------------------------------------
    // 1) ETF 메인 화면용 데이터 (랭킹 + 환율)
    // GET /api/etf/main
    // ---------------------------------------------------
    @GetMapping("/main")
    public ResponseEntity<EtfMainResponse> getEtfMain() {
        List<EtfQuoteDTO> etfs = etfService.getCachedEtfs();
        double usdKrw = fxService.getUsdKrwRateToday();

        EtfMainResponse body = new EtfMainResponse(etfs, usdKrw);
        return ResponseEntity.ok(body);
    }

    // ---------------------------------------------------
    // 2) ETF 주문 화면용 데이터
    // GET /api/etf/order?code=305720&name=KODEX%202차전지
    // ---------------------------------------------------
    @GetMapping("/order")
    public ResponseEntity<EtfOrderResponse> getEtfOrder(
            @RequestParam("code") String code,
            @RequestParam(value = "name", required = false) String name,
            Principal principal
    ) {
        String principalName = (principal != null) ? principal.getName() : null;

        // IRP 계좌 1개를 List로 감싸서 전달
        List<PcontractDTO> accountList = Collections.emptyList();
        String pacc = null;

        if (principalName != null) {
            PcontractDTO dto = stockService.findByIRP(principalName);
            if (dto != null) {
                accountList = List.of(dto);
                pacc = dto.getPacc();
            }
        }

        // 계좌와 종목명이 있으면 해당 계좌에서 이 ETF 보유 여부 조회
        EtfDTO stock = null;
        if (pacc != null && name != null && !name.isBlank()) {
            stock = stockService.findByStock(pacc, name);
        }

        String stockName = (name != null && !name.isBlank()) ? name : code;

        // ETF 랭킹 캐시 스냅샷
        EtfQuoteDTO snap = etfService.findByCode(code);

        EtfOrderResponse body = EtfOrderResponse.builder()
                .code(code)
                .stockName(stockName)
                .pcuid(principalName)
                .accountList(accountList)
                .stock(stock)
                .etfSnap(snap)
                .build();

        return ResponseEntity.ok(body);
    }

    // ---------------------------------------------------
    // 3) ETF 매수 API
    // POST /api/etf/buy  (JSON body)
    // ---------------------------------------------------
    @PostMapping("/buy")
    public ResponseEntity<ResultResponse> buyEtf(
            @RequestBody EtfBuyRequest request,
            Principal principal
    ) {
        // 필요하다면 principal.getName()과 request.pcuid 일치 여부 검증 가능
        stockService.buyProcess(
                request.getPcuid(),
                request.getPstock(),
                request.getPprice(),
                request.getPsum(),
                request.getPname(),
                request.getPacc(),
                request.getCode()
        );

        return ResponseEntity.ok(new ResultResponse("buy"));
    }

    // ---------------------------------------------------
    // 4) ETF 매도 API
    // POST /api/etf/sell  (JSON body)
    // ---------------------------------------------------
    @PostMapping("/sell")
    public ResponseEntity<ResultResponse> sellEtf(
            @RequestBody EtfSellRequest request,
            Principal principal
    ) {
        stockService.sellProcess(
                request.getPsum(),
                request.getPacc(),
                request.getPname(),
                request.getPcuid()
        );

        return ResponseEntity.ok(new ResultResponse("sell"));
    }

    // ==================== 내부 응답/요청 DTO ====================

    @Data
    @AllArgsConstructor
    public static class EtfMainResponse {
        private List<EtfQuoteDTO> etfs;
        private double usdKrw;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @lombok.Builder
    public static class EtfOrderResponse {
        private String code;
        private String stockName;
        private String pcuid;
        private List<PcontractDTO> accountList;
        private EtfDTO stock;
        private EtfQuoteDTO etfSnap;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EtfBuyRequest {
        private String pcuid;
        private Integer pstock;
        private Integer pprice;
        private Integer psum;
        private String pname;
        private String pacc;
        private String code;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EtfSellRequest {
        private Integer psum;
        private String pacc;
        private String pname;
        private String pcuid;
        private String code;
    }

    @Data
    @AllArgsConstructor
    public static class ResultResponse {
        private String result; // "buy" 또는 "sell"
    }
}

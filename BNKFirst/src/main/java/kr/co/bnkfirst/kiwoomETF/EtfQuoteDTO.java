package kr.co.bnkfirst.kiwoomETF;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EtfQuoteDTO {

    private int    rank;           // 화면용 순위 (1,2,3...)
    private String code;           // stk_cd
    private String name;           // stk_nm

    private long   price;          // close_pric (현재가)
    private double changeRate;     // pre_rt (%)

    // NAV 관련
    private double nav;            // nav
    private double premiumRate;    // (price - nav) / nav * 100  → 괴리율(%)

    private String traceIndexName; // trace_idex_nm (추적지수명, 예: KOSPI200)
}
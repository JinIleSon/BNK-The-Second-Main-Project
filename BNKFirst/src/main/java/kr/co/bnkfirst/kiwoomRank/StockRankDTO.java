package kr.co.bnkfirst.kiwoomRank;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StockRankDTO {
    private int rank;          // now_rank
    private String code;       // stk_cd
    private String name;       // stk_nm
    private long price;        // cur_prc (절대값)
    private double changeRate; // flu_rt (%)
    private long amount;       // trde_prica (거래대금, 원 or 만원 단위 – 문서 기준)
}

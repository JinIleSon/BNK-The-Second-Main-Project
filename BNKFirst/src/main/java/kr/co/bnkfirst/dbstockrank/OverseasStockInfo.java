package kr.co.bnkfirst.dbstockrank;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// 해외 종목 기본정보
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class OverseasStockInfo {
    private String marketCodeNyNaAm;  // "NY" / "NA" / "AM" (종목조회용)
    private String marketCodeFyFnFa;  // "FY" / "FN" / "FA" (현재가용)
    private String code;              // Iscd
    private String name;              // KorIsnm
}

package kr.co.bnkfirst.dbstock;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class OverseasOrderbookDto {
    private String code;
    private String market; // FY/FN/FA
    private BigDecimal price;      // 현재가
    private BigDecimal changeRate; // 전일 대비 등락률(%)

    // 1~5호가
    private BigDecimal[] askp = new BigDecimal[5];
    private BigDecimal[] bidp = new BigDecimal[5];
    private long[] askQty = new long[5];
    private long[] bidQty = new long[5];
}

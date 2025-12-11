package kr.co.bnkfirst.dbstockrank;

// 멀티현재가 응답에서 뽑을 값

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DbOverseasPriceDto {
    private String code;
    private String name;
    private double price;       // Prpr
    private double changeRate; // PrdyCtr(t)
    private long amount;      // 거래대금 필드 (예: AcmlTrPbmn)

    // 새로 추가
    private double bid;  // bidp1
    private double ask;  // askp1

}

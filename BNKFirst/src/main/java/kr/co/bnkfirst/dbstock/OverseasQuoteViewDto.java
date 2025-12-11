package kr.co.bnkfirst.dbstock;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OverseasQuoteViewDto {

    private String code;       // 종목코드
    private String name;       // 종목명

    private double price;      // 현재가
    private double changeRate; // 등락률(%)
    private long amount;       // 거래대금

    private double bid;        // 매수1호가
    private double ask;        // 매도1호가

    // 프론트가 바로 쓰도록 색/상승 or 하락 방향도 포함 가능
    private String sign;       // "+", "-", ""
    private String color;      // red / blue / gray
}
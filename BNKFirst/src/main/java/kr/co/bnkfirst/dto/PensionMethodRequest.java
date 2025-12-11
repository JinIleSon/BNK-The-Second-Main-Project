package kr.co.bnkfirst.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PensionMethodRequest {

    /** 연금 수령주기(개월) : 1, 3, 6, 12 중 하나 */
    private Integer paymentCycleMonths;

    /** 수령기간(년) */
    private Integer years;

    /** 월 수령금액(만원 단위로 입력받음) */
    private Long monthlyAmountMan;

    /** 연금부리이율(연 % 단위, 예: 1.0) */
    private Double annualRatePercent;
}

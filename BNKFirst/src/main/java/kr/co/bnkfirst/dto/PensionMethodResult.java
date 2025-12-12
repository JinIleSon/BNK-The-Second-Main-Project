package kr.co.bnkfirst.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PensionMethodResult {

    /** 연금 수령주기(개월) */
    private int paymentCycleMonths;

    /** 수령기간(년) */
    private int years;

    /** 월 수령금액(만원 단위) */
    private long monthlyAmountMan;

    /** 연금부리이율(연 %) */
    private double annualRatePercent;

    /** 현재 필요금액(원) */
    private long currentNeedAmountWon;

    /** 연금수령 총액(원) */
    private long totalPayoutAmountWon;

    /** 그래프용 / 화면표시용 (만원 단위) */
    private long currentNeedAmountMan;
    private long totalPayoutAmountMan;
}

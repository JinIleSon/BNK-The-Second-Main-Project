package kr.co.bnkfirst.dto;

import lombok.Data;

@Data
public class RetirementCalcRequest {
    // 01. 현재 나이 / 은퇴 나이
    private int currentAge;              // 현재나이 (예: 35)
    private int retireAge;               // 은퇴나이 (예: 60)

    // 02. 기대수명
    private int lifeExpectancy;          // 기대수명 (예: 80)

    // 03. 현재 월 생활비
    private long currentMonthlyLivingCost;  // 현재 월 생활비(만원, 예: 140)

    // 04. 저축기간 / 월 저축금액
    private int savingYears;             // 저축기간(년, 예: 10)
    private long monthlySavingAmount;    // 월 저축금액(만원, 예: 100)

    // 05. 투자수익률 / 물가상승률 (연간 %, 예: 4.0 / 3.0)
    private double expectedReturnRate;   // 투자수익률(%)
    private double inflationRate;        // 물가상승률(%)
}

package kr.co.bnkfirst.dto;

import lombok.Data;

@Data
public class RetirementCalcResult {
    // 입력에서 파생된 기본 정보
    private int workingYears;             // 근로기간(은퇴까지) = retireAge - currentAge
    private int retiredYears;             // 은퇴 후 기간      = lifeExpectancy - retireAge

    // 월 생활비 관련
    private long baseMonthlyLivingCost;   // 현재 월 생활비의 70% (만원, 반올림)
    private long retirementMonthlyLivingCost; // 은퇴시점 월 생활비 (만원, 반올림)
    private double livingIncreaseRate;    // 월 생활비 상승률(%) – 현재(70%) → 은퇴시점

    // 총 생활비
    private long currentTotalLivingCost;      // 현재 총 생활비 (현재 가치, 만원)
    private long retirementTotalLivingCost;   // 은퇴시점 총 생활비 (미래 가치, 만원)

    // 자금 관련
    private long neededRetirementFund;   // 필요한 은퇴자금(=은퇴시점 총 생활비)
    private long preparedFund;           // 준비 가능한 자금(적립식 저축 FV)
    private long shortageFund;           // 부족 자금
}

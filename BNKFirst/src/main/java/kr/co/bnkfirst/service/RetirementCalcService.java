package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.RetirementCalcRequest;
import kr.co.bnkfirst.dto.RetirementCalcResult;
import org.springframework.stereotype.Service;

@Service
public class RetirementCalcService {
    public RetirementCalcResult calculate(RetirementCalcRequest req) {

        int workingYears = req.getRetireAge() - req.getCurrentAge();   // 근로기간
        int retiredYears = req.getLifeExpectancy() - req.getRetireAge(); // 표시용(25년)
        int retiredYearsEffective = retiredYears + 1; // 실제 계산에 쓰는 연수(+1년)
        int retiredMonths = retiredYearsEffective * 12;

        // 1) 현재 월 생활비의 70%
        double baseMonthly = req.getCurrentMonthlyLivingCost() * 0.7; // 만원

        // 2) 연 물가상승률
        double annualInflation = req.getInflationRate() / 100.0;

        // 3) 은퇴시점 월 생활비
        double retirementMonthly =
                baseMonthly * Math.pow(1 + annualInflation, workingYears);

        // 4) 은퇴시점 총 생활비(=필요한 은퇴자금)
        double retirementTotal =
                retirementMonthly * retiredMonths;

        // 5) 현재 총 생활비 = 은퇴시점 총 생활비를 물가상승률로 근로기간만큼 할인
        double currentTotal =
                retirementTotal / Math.pow(1 + annualInflation, workingYears);

        double neededFund = retirementTotal;

        // 6) 준비 가능한 자금 쪽(적립식)은 기존 코드처럼 유지
        double annualReturn = req.getExpectedReturnRate() / 100.0;
        int savingYears = req.getSavingYears();
        double yearlyPayment = req.getMonthlySavingAmount() * 12;

        double preparedFund;
        if (annualReturn > 0) {
            preparedFund = yearlyPayment *
                    (Math.pow(1 + annualReturn, savingYears) - 1)
                    / annualReturn;
        } else {
            preparedFund = yearlyPayment * savingYears;
        }

        double shortage = Math.max(0, neededFund - preparedFund);

        // 7) DTO 세팅
        RetirementCalcResult result = new RetirementCalcResult();
        result.setWorkingYears(workingYears);
        result.setRetiredYears(retiredYears); // 화면에는 25년만 보여주고, +1은 내부 계산용

        result.setBaseMonthlyLivingCost(Math.round(baseMonthly));
        result.setRetirementMonthlyLivingCost(Math.round(retirementMonthly));
        result.setLivingIncreaseRate(
                (retirementMonthly / baseMonthly - 1.0) * 100.0
        );

        result.setCurrentTotalLivingCost(Math.round(currentTotal));
        result.setRetirementTotalLivingCost(Math.round(retirementTotal));

        result.setNeededRetirementFund(Math.round(neededFund));
        result.setPreparedFund(Math.round(preparedFund));
        result.setShortageFund(Math.round(shortage));

        return result;
    }
}

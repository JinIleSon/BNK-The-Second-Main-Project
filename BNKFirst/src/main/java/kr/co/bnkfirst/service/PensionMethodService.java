package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.PensionMethodRequest;
import kr.co.bnkfirst.dto.PensionMethodResult;
import org.springframework.stereotype.Service;

@Service
public class PensionMethodService {
    public PensionMethodResult calculate(PensionMethodRequest req) {

        int cycleMonths       = req.getPaymentCycleMonths(); // 1,3,6,12
        int years             = req.getYears();
        long monthlyAmtMan    = req.getMonthlyAmountMan();   // 만원 단위
        double annualRatePct  = req.getAnnualRatePercent();  // 예: 1.0

        // ① 1년에 몇 번 지급되는지
        int paymentsPerYear = 12 / cycleMonths;

        // ② 전체 지급 횟수 n
        int n = years * paymentsPerYear;

        // ③ 주기별 이자율 i
        double i = (annualRatePct / 100.0) / paymentsPerYear;

        // ④ 1회 지급액(PMT) - 하나은행 방식: 월 금액 그대로를 주기 지급액으로 사용
        double paymentPerPeriodWon = monthlyAmtMan * 10_000.0;  // 원 단위로 환산

        // ⑤ 연금 수령 총액 (단리 합산)
        double totalPayoutWon = paymentPerPeriodWon * n;

        // ⑥ 현재 필요금액(연금 현가)
        double pvWon;
        if (i == 0.0) {
            // 이율 0%면 그냥 합계
            pvWon = totalPayoutWon;
        } else {
            pvWon = paymentPerPeriodWon * (1 - Math.pow(1 + i, -n)) / i;
        }

        // ⑦ DTO 세팅
        PensionMethodResult res = new PensionMethodResult();
        res.setPaymentCycleMonths(cycleMonths);
        res.setYears(years);
        res.setMonthlyAmountMan(monthlyAmtMan);
        res.setAnnualRatePercent(annualRatePct);

        res.setTotalPayoutAmountWon(Math.round(totalPayoutWon));
        res.setCurrentNeedAmountWon(Math.round(pvWon));

        res.setTotalPayoutAmountMan(Math.round(totalPayoutWon / 10_000.0));
        res.setCurrentNeedAmountMan(Math.round(pvWon / 10_000.0));

        return res;
    }
}

package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.PensionAssetRequest;
import kr.co.bnkfirst.dto.PensionAssetResult;
import org.springframework.stereotype.Service;

@Service
public class PensionAssetService {
    public PensionAssetResult calculate(PensionAssetRequest req) {

        // 1) 기본 값 세팅
        int savingYears = req.getRetireAge() - req.getCurrentAge(); // 운용기간(년)
        int totalMonths = req.getPensionYears() * 12;              // 총 수령개월 수

        double investRate = req.getInvestAnnualRatePercent() / 100.0;     // 운용수익률(연)
        double pensionRate = req.getPensionAnnualRatePercent() / 100.0;   // 연금부리이율(연)

        long currentAsset = req.getCurrentAssetMan() * 10_000L; // 만원 → 원

        // 2) 은퇴 시점 자산: 현재자산 × (1+운용수익률)^저축기간
        double retirementAssetDouble =
                currentAsset * Math.pow(1 + investRate, savingYears);

        // 3) 연금부리이율 → 월이율로 변환
        double monthlyRate = Math.pow(1 + pensionRate, 1.0 / 12.0) - 1.0;

        // 4) 매월 연금액 = A × i / (1 - (1+i)^-n)
        double monthlyPensionDouble =
                retirementAssetDouble * monthlyRate
                        / (1 - Math.pow(1 + monthlyRate, -totalMonths));

        long retirementAsset = Math.round(retirementAssetDouble);
        long monthlyPension = Math.round(monthlyPensionDouble);

        return PensionAssetResult.builder()
                .currentAge(req.getCurrentAge())
                .retireAge(req.getRetireAge())
                .pensionYears(req.getPensionYears())

                .currentAsset(currentAsset)
                .currentAssetMan(currentAsset / 10_000L)

                .retirementAsset(retirementAsset)
                .retirementAssetMan(Math.round(retirementAssetDouble / 10_000L))

                .monthlyPension(monthlyPension)
                .build();
    }
}

package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.PensionAssetRequest;
import kr.co.bnkfirst.dto.PensionAssetResult;
import kr.co.bnkfirst.dto.PensionMethodRequest;
import kr.co.bnkfirst.dto.PensionMethodResult;
import kr.co.bnkfirst.service.PensionAssetService;
import kr.co.bnkfirst.service.PensionMethodService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
@RequiredArgsConstructor
public class PensionCalcController {

    private final PensionMethodService pensionMethodService;
    private final PensionAssetService pensionAssetService;

    @GetMapping("/mypage/calc/pension")
    public String calcPension(@ModelAttribute("form") PensionMethodRequest form,
                              @ModelAttribute("assetForm") PensionAssetRequest assetForm,
                              Model model) {

        // 연금부리이율만 기본값 1.0 설정
        if (form.getAnnualRatePercent() == null) {
            form.setAnnualRatePercent(1.0);
        }

        // 2) 현재 보유자산 기준 - 기본값 (하나은행 예시와 비슷하게)
        if (assetForm.getCurrentAge() == 0) { // 처음 들어왔을 때만 세팅
            assetForm.setCurrentAge(35);
            assetForm.setRetireAge(55);
            assetForm.setInvestAnnualRatePercent(3.0);  // 운용수익률 3%
            assetForm.setPensionAnnualRatePercent(1.0); // 연금부리이율 1%
        }

        model.addAttribute("assetForm", assetForm);
        model.addAttribute("form", form);
        return "mypage/mypage_calcPension";
    }

    @PostMapping("/mypage/calc/pension")
    public String calcPensionMethod(@ModelAttribute("form") PensionMethodRequest form, Model model) {

        PensionMethodResult result = pensionMethodService.calculate(form);

        model.addAttribute("form", form);
        model.addAttribute("result", result);
        return "mypage/mypage_calcPensionMethodResult";
    }

    @PostMapping("/mypage/calc/pension/asset")
    public String calcPensionAsset(@ModelAttribute("assetForm") PensionAssetRequest assetForm,
                                   Model model) {

        PensionAssetResult result = pensionAssetService.calculate(assetForm);

        model.addAttribute("assetForm", assetForm);
        model.addAttribute("result", result);
        return "mypage/mypage_calcPensionMoneyResult";
    }
}

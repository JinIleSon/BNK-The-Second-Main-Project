package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.RetirementCalcRequest;
import kr.co.bnkfirst.dto.RetirementCalcResult;
import kr.co.bnkfirst.service.RetirementCalcService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequiredArgsConstructor
public class RetirementCalcController {

    private final RetirementCalcService retirementCalcService;

    @GetMapping("/mypage/calc")
    public String calc(Model model) {
        RetirementCalcRequest form = new RetirementCalcRequest();
        form.setCurrentAge(35);
        form.setRetireAge(55);
        form.setLifeExpectancy(80);
        form.setCurrentMonthlyLivingCost(200);
        form.setSavingYears(10);
        form.setMonthlySavingAmount(100);
        form.setExpectedReturnRate(4.0);
        form.setInflationRate(3.0);


        model.addAttribute("form", form);
        return "mypage/mypage_calc";
    }

    @PostMapping("/mypage/calc")
    public String showResult(@ModelAttribute("form")RetirementCalcRequest form, Model model) {

        RetirementCalcResult result = retirementCalcService.calculate(form);

        model.addAttribute("form", form);
        model.addAttribute("result", result);
        return "mypage/mypage_calcResult";
    }
}

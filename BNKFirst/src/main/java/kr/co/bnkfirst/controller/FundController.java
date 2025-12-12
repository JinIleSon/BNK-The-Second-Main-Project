package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@Slf4j
@RequiredArgsConstructor
public class FundController {

    private final ProductService productService;

    @GetMapping("/product/fund/list")
    public String fundList(Model model){
        model.addAttribute("fund", productService.selectFund());
        return "fund/fund_list";
    }

    @GetMapping("/product/TDF/list")
    public String TDFList(){
        return "fund/TDF_list";
    }

    @GetMapping("/product/ETF/list")
    public String ETFList(){
        return "fund/ETF_list";
    }
}

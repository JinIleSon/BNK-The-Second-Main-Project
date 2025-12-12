package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.service.EmployeeService;
import kr.co.bnkfirst.service.ContributionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@RequiredArgsConstructor
public class CorporateController {

    private final EmployeeService employeeService;          // 주입됨
    private final ContributionService contributionService;  // ← 반드시 추가

    /** 기업 메인 (대시보드) */
    @GetMapping("/corporate/main")
    public String main(Model model) {

        // 1) 전체 직원 수
        int totalEmployees = employeeService.getTotalEmployees();

        // 2) 전체 적립금 합계
        long totalBalance = contributionService.getTotalAccumulatedAmount();

        // 3) 이번 달 납입 예정
        long expectedThisMonth = contributionService.getExpectedContributionForMonth();

        // View 로 전달
        model.addAttribute("totalEmployees", totalEmployees);
        model.addAttribute("totalBalance", totalBalance);
        model.addAttribute("expectedThisMonth", expectedThisMonth);

        return "corporate/main/corporate_main";
    }

    /** 고객센터 */
    @GetMapping("/corporate/cs")
    public String cs() {
        return "corporate/cs/cs_main";
    }

}

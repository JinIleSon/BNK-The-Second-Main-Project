package kr.co.bnkfirst.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class IRPaccountController {

    //IRP계좌개설 1페이지(메인)
    @GetMapping("/irp/account/main")
    public String irpAccountPage() {
        // templates/account/IRPaccount_main.html
        return "account/IRPaccount_main";
    }

    //IRP계좌개설 2페이지
    @GetMapping("/irp/account/page2")
    public String irpAccountPage2() {
        return "account/IRPaccount_page2";
    }

    //IRP계좌개설 3페이지
    @GetMapping("/irp/account/page3")
    public String irpAccountPage3() {
        return "account/IRPaccount_page3";
    }

    //IRP계좌개설 4페이지 - QR 인증
    @GetMapping("/irp/account/page4")
    public String irpAccountPage4() {
        return "account/IRPaccount_page4";
    }

    //IRP계좌개설 5페이지 -  본인 명의 계좌인증
    @GetMapping("/irp/account/page5")
    public String irpAccountPage5() {
        return "account/IRPaccount_page5";
    }

    //IRP계좌개설 6페이지 -  약관동의
    @GetMapping("/irp/account/page6")
    public String irpAccountPage6() {
        return "account/IRPaccount_page6";
    }

    //IRP계좌개설 7페이지 -  개인정보 확인
    @GetMapping("/irp/account/page7")
    public String irpAccountPage7() {
        return "account/IRPaccount_page7";
    }

    //IRP계좌개설 8페이지 -  계좌 비밀번호 생성
    @GetMapping("/irp/account/page8")
    public String irpAccountPage8() {
        return "account/IRPaccount_page8";
    }

    //IRP계좌개설 9페이지 -  최종 페이지
    @GetMapping("/irp/account/page9")
    public String irpAccountPage9() {
        return "account/IRPaccount_page9";
    }

}

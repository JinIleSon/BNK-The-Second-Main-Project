package kr.co.bnkfirst.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class RetirementInfoController {

    @GetMapping("/retirement-renew/intro/why-pension")
    public String whyPension(){
        return "retirement-renew/intro/why-pension/why-pension";
    }

    @GetMapping("/retirement-renew/system/db")
    public String db(){
        return "retirement-renew/system/db/db";
    }

    @GetMapping("/retirement-renew/operation/intro-process")
    public String introProcess(){
        return "retirement-renew/operation/intro-process/intro-process";
    }

    @GetMapping("/retirement-renew/tax/tax-benefit")
    public String taxBenefit(){
        return "retirement-renew/tax/tax-benefit/tax-benefit";
    }

    @GetMapping("/retirement-renew/why-bnk/bnk-strong")
    public String bnkStrong(){
        return "retirement-renew/why-bnk/bnk-strong/bnk-strong";
    }

    @GetMapping("/retirement-renew/nps-plan/nps-plan")
    public String npsPlan(){
        return "retirement-renew/nps-plan/nps-plan/nps-plan";
    }

    @GetMapping("/retirement-renew/portal-error/portal-error")
    public String portalError(){
        return "retirement-renew/portal-error/portal-error/portal-error";
    }
}

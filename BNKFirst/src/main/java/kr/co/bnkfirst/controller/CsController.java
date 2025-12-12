package kr.co.bnkfirst.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Slf4j
@Controller
public class CsController {
    //consultation
    @GetMapping("/cs/consultation/document")
    public String cs_document() {
        return "cs/consultation/cs_document";
    }
    @GetMapping("/cs/consultation/FAQ")
    public String cs_faq() {
        return "cs/consultation/cs_faq";
    }
    @GetMapping("/cs/consultation/findStore")
    public String cs_findstore() {
        return "cs/consultation/cs_findstore";
    }
    @GetMapping("/cs/consultation/Q&A")
    public String cs_qna() {
        return "cs/consultation/cs_qna";
    }

    //data room
    @GetMapping("/cs/data_room/deposit")
    public String deposit() {
        return "cs/data_room/cs_deposit";
    }
    @GetMapping("/cs/data_room/fund")
    public String fund() {
        return "cs/data_room/cs_fund";
    }
    @GetMapping("/cs/data_room/loan")
    public String loan() {
        return "cs/data_room/cs_loan";
    }
    @GetMapping("/cs/data_room/trust")
    public String trust() {
        return "cs/data_room/cs_trust";
    }

    //consumerProtection
    @GetMapping("/cs/consumerProtection")
    public String consumerProtection() {
        return "cs/consumerProtection/cs_consumerProtection";
    }

    //howUse
    @GetMapping("/cs/howUse/feeInfo")
    public String feeInfo() {
        return "cs/howUse/cs_feeInfo";
    }
    @GetMapping("/cs/howUse/pwInfo")
    public String pwInfo() {
        return "cs/howUse/cs_pwInfo";
    }
    @GetMapping("/cs/howUse/regProcess")
    public String regProcess() {
        return "cs/howUse/cs_regProcess";
    }
    @GetMapping("/cs/howUse/serviceTime")
    public String serviceTime() {
        return "cs/howUse/cs_serviceTime";
    }

    //infoProtect
    @GetMapping("/cs/infoProtect/agencyGuide")
    public String agencyGuide() {
        return "cs/infoProtect/cs_agencyGuide";
    }
    @GetMapping("/cs/infoProtect/complaintProcessing")
    public String complaintProcessing() {
        return "cs/infoProtect/cs_complaintProcessing";
    }
    @GetMapping("/cs/infoProtect/financialProtection")
    public String financialProtection() {
        return "cs/infoProtect/cs_financialProtection";
    }
    @GetMapping("/cs/infoProtect/protectionInformation")
    public String protectionInformation() {
        return "cs/infoProtect/cs_protectionInformation";
    }

    //main
    @GetMapping("/cs/main")
    public String cs_main() {
        return "cs/main/cs_main";
    }

    //productsRoom
    @GetMapping("/cs/productsRoom/AnyProduct")
    public String AnyProduct() {
        return "cs/productsRoom/cs_AnyProduct";
    }
    @GetMapping("/cs/productsRoom/bankManual")
    public String bankManual() {
        return "cs/productsRoom/cs_bankManual";
    }
    @GetMapping("/cs/productsRoom/depositProduct")
    public String depositProduct() {
        return "cs/productsRoom/cs_depositProduct";
    }
    @GetMapping("/cs/productsRoom/serviceFee")
    public String serviceFee() {
        return "cs/productsRoom/cs_serviceFee";
    }
}

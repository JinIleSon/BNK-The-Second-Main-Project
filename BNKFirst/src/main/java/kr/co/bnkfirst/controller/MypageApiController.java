/*
    날짜 : 2025.12.12.
    이름 : 강민철
    내용 : Mypage 정보 가져오기 API
 */
// src/main/java/kr/co/bnkfirst/controller/MypageApiController.java
package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.dto.mypage.DealDTO;
import kr.co.bnkfirst.dto.product.FundDTO;
import kr.co.bnkfirst.dto.product.PcontractDTO;
import kr.co.bnkfirst.service.MypageService;
import kr.co.bnkfirst.service.ProductService;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/mypage")
@RequiredArgsConstructor
@Slf4j
public class MypageApiController {

    private final MypageService mypageService;
    private final ProductService productService;

    // ----------------------------------------------------
    // 1) 마이페이지 메인 데이터
    //    GET /api/mypage/main
    // ----------------------------------------------------
    @GetMapping("/main")
    public ResponseEntity<MypageMainResponse> getMypageMain(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        String mid = principal.getName();

        UsersDTO user = mypageService.findById(mid);
        List<DealDTO> dealList = mypageService.findByDealList(mid);
        List<FundDTO> fundList = mypageService.findByFund(mid);
        long balance = mypageService.findByBalance(mid)
                + mypageService.findByFundBalance(mid);
        List<PcontractDTO> contractList = mypageService.findByContract(mid);
        List<?> documentList = mypageService.findByDocumentList(mid);
        List<PcontractDTO> etfList = mypageService.selectEtf(mid);

        MypageMainResponse body = MypageMainResponse.builder()
                .user(user)
                .dealList(dealList)
                .fundList(fundList)
                .balance(balance)
                .contractList(contractList)
                .documentList(documentList)
                .etfList(etfList)
                .build();

        return ResponseEntity.ok(body);
    }

    // ----------------------------------------------------
    // 2) 마이페이지 상품 요약(/mypage/prod) 데이터
    //    GET /api/mypage/prod
    // ----------------------------------------------------
    @GetMapping("/prod")
    public ResponseEntity<MypageProdResponse> getMypageProd(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        String mid = principal.getName();

        long plus = mypageService.findBySumPlusDbalance(mid);
        long minus = mypageService.findBySumMinusDbalance(mid);
        List<DealDTO> dealList = mypageService.findByDealList(mid);

        List<PcontractDTO> totalList = new ArrayList<>();
        totalList.addAll(mypageService.findByFundContract(mid));
        totalList.addAll(mypageService.selectEtf(mid));

        long balance = mypageService.findByBalance(mid)
                + mypageService.findByFundBalance(mid);

        MypageProdResponse body = MypageProdResponse.builder()
                .plus(plus)
                .minus(minus)
                .dealList(dealList)
                .contractList(totalList)
                .balance(balance)
                .build();

        return ResponseEntity.ok(body);
    }

    // ----------------------------------------------------
    // 3) 계좌이체 (/mypage/prod POST) API 버전
    //    POST /api/mypage/transfer
    //    Body: { dbalance, dwho, myAcc, yourAcc }
    // ----------------------------------------------------
    @PostMapping("/transfer")
    public ResponseEntity<Boolean> transfer(
            @RequestBody TransferRequest req,
            Principal principal
    ) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(false);
        }
        String mid = principal.getName();
        log.info("transfer mid={}, dbalance={}, dwho={}, myAcc={}, yourAcc={}",
                mid, req.getDbalance(), req.getDwho(), req.getMyAcc(), req.getYourAcc());

        mypageService.transfer(
                mid,
                req.getDbalance(),
                req.getDwho(),
                req.getMyAcc(),
                req.getYourAcc()
        );

        // 예외 없이 여기까지 왔다면 true
        return ResponseEntity.ok(true);
    }

    // ----------------------------------------------------
    // 4) 변경 해지용 상품 목록 (/mypage/prod/cancel GET)
    //    GET /api/mypage/prodCancel
    // ----------------------------------------------------
    @GetMapping("/prodCancel")
    public ResponseEntity<List<PcontractDTO>> getProdCancelList(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        String mid = principal.getName();
        List<PcontractDTO> list = mypageService.findByFundContract(mid);
        return ResponseEntity.ok(list);
    }

    // ----------------------------------------------------
    // 5) 상품 해지 처리 (/mypage/prod/cancel POST)
    //    POST /api/mypage/prodCancel
    //    Body: { pacc, pbalance, recvAcc, pcpid }
    // ----------------------------------------------------
    @PostMapping("/prodCancel")
    public ResponseEntity<Boolean> prodCancel(
            @RequestBody ProdCancelRequest req,
            Principal principal
    ) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(false);
        }
        String mid = principal.getName();
        log.info("prodCancel mid={}, pacc={}, pbalance={}, recvAcc={}, pcpid={}",
                mid, req.getPacc(), req.getPbalance(), req.getRecvAcc(), req.getPcpid());

        mypageService.deleteContractProcess(
                req.getPbalance(),
                req.getRecvAcc(),
                mid,
                req.getPcpid()
        );

        return ResponseEntity.ok(true);
    }

    // ----------------------------------------------------
    // 6) (이미 존재하는 변경 매도/매수 API도 여기와 맞춰 쓰이도록)
    //    /api/mypage/editList, /api/mypage/editSell, /api/mypage/editBuy
    //    는 기존 MypageController 에 그대로 두고 사용하면 됨.
    // ----------------------------------------------------


    // =================== 내부 DTO ===================

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class MypageMainResponse {
        private UsersDTO user;
        private List<DealDTO> dealList;
        private List<FundDTO> fundList;
        private long balance;
        private List<PcontractDTO> contractList;
        private List<?> documentList;
        private List<PcontractDTO> etfList;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class MypageProdResponse {
        private long plus;
        private long minus;
        private List<DealDTO> dealList;
        private List<PcontractDTO> contractList;
        private long balance;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TransferRequest {
        private int dbalance;
        private String dwho;
        private String myAcc;
        private String yourAcc;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProdCancelRequest {
        private String pacc;
        private int pbalance;
        private String recvAcc;
        private String pcpid;
    }
}

package kr.co.bnkfirst.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BranchDTO {

    /* =========================
       내부 DB용 (BRANCH TABLE)
       ========================= */
    private int brid;
    private String brname;
    private String braddr;
    private String brtel;
    private String brfax;

    // ★ 반드시 필요 : 지점 분류용 TYPE
    private String type;     // 영업점 / 365코너 / 24/365코너 / 대여금고 / 외화ATM


    /* =========================
       외부 API (KFTC용)
       ========================= */
    private String bankCode;
    private String bankName;
    private String branchCode;
    private String branchName;
    private String address;
    private String tel;
    private String latitude;
    private String longitude;

}

package kr.co.bnkfirst.dto.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FundDTO {

    private String fid;
    private String fname;
    private String famc;
    private int frlvl;
    private String ftype;
    private float frefpr;
    private String fsetdt;
    private float ftc;
    private float fm1pr;
    private float fm3pr;
    private float fm6pr;
    private float fm12pr;
    private float facmpr;

    // mypage - 나의 투자용 필드 추가(손진일)
    private String pacc;
    private LocalDateTime pnew;
    private LocalDateTime pend;
    private int pbalance;

    // fund_list - 모달 페이지용 필드 추가(손진일)
    private String basedt;
    private String evaltype;
    private String mgmtcomp;
    private String grade3y;
    private String grade5y;
    private String relatedfund;
    private String investregion;
    private String past2023;
    private String past2024;
    private String fee1y;
    private String fee3y;
    private String startinfo;
    private String salesfee;
    private String familysize;
    private String trustfee;
    private String aum;
    private String redeemfee;
    private String chart1;
    private String chart2;

    // 필드 추가 - 손진일
    private String pname;
}

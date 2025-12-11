package kr.co.bnkfirst.dto;

import lombok.Data;

@Data
public class MydataAccountDTO {

    private Long myaccid;        // PK
    private String mid;          // 사용자 ID
    private String institution;  // 금융기관명
    private String accounttype;  // 계좌 유형 (IRP, 연금저축 등)
    private String productname;  // 상품명
    private String accountnumber; // 계좌번호 (마스킹)
    private Double balance;      // 잔고
    private Double yieldrate;    // 수익률
    private String isretirement; // 퇴직연금 여부 (Y/N)
    private String createdat;    // 생성일
}

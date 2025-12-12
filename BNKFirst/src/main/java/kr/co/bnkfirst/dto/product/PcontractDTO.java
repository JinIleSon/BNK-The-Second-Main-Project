package kr.co.bnkfirst.dto.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PcontractDTO {
    private String pcuid;
    private String pcpid;
    private String pccptp;
    private String pccprd;
    private String pcwcat;
    private String pcwdac;
    private int pcmdps;
    private int pcgamn;
    private String pcatapp;
    private int pcatdt;
    private String pcatac;
    private String pccns;
    private String pcntcs;
    private String pcnapw;
    private String pacc;
    @CreationTimestamp
    private LocalDateTime pnew;
    @CreationTimestamp
    private LocalDateTime pend;
    private int pbalance;

    // 추가 컬럼 - 손진일
    private String pname;
    private String ptype;
    private float phirate;
    private float pbirate;

    // 추가 컬럼 - 손진일
    private String mname;
    private String mphone;
    private String pwtpi;

    // 추가 컬럼 - 강민철
    private Float pcwtpi;
    private String type;

    // 추가 컬럼 - 펀드 계좌용(손진일)
    private String fid;
    private String fname;
    private String famc;
    private String frlvl;
    private String ftype;
    private String frefpr;
    private String fsetdt;
    private String ftc;
    private String fm1pr;
    private String fm3pr;
    private String fm6pr;
    private String fm12pr;
    private String facmpr;

    // 추가 컬럼 - ETF 조회용 필드 추가
    private Integer pstock; // 보유 수량
    private Integer pprice; // 매수 단가
    private Integer psum; // 평가 금액(또는 매수 금액)
    private String code; // 해당 종목 code
}

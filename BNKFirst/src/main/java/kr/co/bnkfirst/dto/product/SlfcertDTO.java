package kr.co.bnkfirst.dto.product;

import kr.co.bnkfirst.entity.product.Slfcert;
import lombok.*;

import java.time.LocalDate;

/*
    날짜 : 2025.11.20.
    이름 : 강민철
    내용 : 본인확인서 DTO (SLFCERT 테이블)
 */

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
public class SlfcertDTO {
    private int id;
    private String cusid;
    private String ftype;
    private String signdt;
    private String expdt;
    private String sts;
    private int taxyr;
    private String krres;
    private String others;
    private String natcd;
    private String name;
    private String gender;
    private String brthdt;
    private String zipcd;
    private String addr1;
    private String addr2;
    private String enlnm;
    private String enfnm;
    private String phone;
    private String crtdt;
    private String uptdt;

    public Slfcert toEntity() {
        return Slfcert.builder()
                .cusid(cusid)
                .ftype(ftype)
                .sts(sts)
                .taxyr(taxyr)
                .krres(krres)
                .others(others)
                .natcd(natcd)
                .name(name)
                .gender(gender)
                .brthdt(LocalDate.parse(brthdt))
                .zipcd(zipcd)
                .addr1(addr1)
                .addr2(addr2)
                .enlnm(enlnm)
                .enfnm(enfnm)
                .phone(phone)
                .build();
    }
}

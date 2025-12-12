package kr.co.bnkfirst.entity.product;

import jakarta.persistence.*;
import kr.co.bnkfirst.dto.product.SlfcertDTO;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
@Entity
@Table(name = "SLFCERT")
public class Slfcert {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "slfcert_seq")
    @SequenceGenerator(
            name = "slfcert_seq",
            sequenceName = "SLFCERT_SEQ",
            allocationSize = 1  // JPA의 기본값은 50
    )
    private Integer id;
    private String cusid;
    private String ftype;

    @CreationTimestamp
    private LocalDate signdt;

    @Column(insertable = false, updatable = false)
    private LocalDate expdt;

    private String sts;
    private int taxyr;
    private String krres;
    private String others;
    private String natcd;
    private String name;
    private String gender;
    private LocalDate brthdt;
    private String zipcd;
    private String addr1;
    private String addr2;
    private String enlnm;
    private String enfnm;
    private String phone;

    @CreationTimestamp
    private LocalDateTime crtdt;
    @Column(insertable = false, updatable = false)
    private LocalDateTime uptdt;

    public SlfcertDTO toDTO() {
        return SlfcertDTO.builder()
                .id(id)
                .cusid(cusid)
                .ftype(ftype)
                .sts(sts)
                .taxyr(taxyr)
                .krres(krres)
                .others(others)
                .natcd(natcd)
                .name(name)
                .gender(gender)
                .brthdt(brthdt.toString())
                .zipcd(zipcd)
                .addr1(addr1)
                .addr2(addr2)
                .enlnm(enlnm)
                .enfnm(enfnm)
                .phone(phone)
                .crtdt(crtdt.toString())
                .uptdt(uptdt != null ? uptdt.toString() : "")
                .build();
    }
}

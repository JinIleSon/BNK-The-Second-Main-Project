package kr.co.bnkfirst.entity.product;

import jakarta.persistence.*;
import kr.co.bnkfirst.dto.product.ProductDTO;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Nationalized;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
@Entity
@Table(name = "product")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    @Column(length = 500)
    private String pid;
    @Nationalized
    @Column(length = 500)
    private String ptype;
    @Nationalized
    @Column(length = 500)
    private String pname;
    @Column(name = "PBIRATE", columnDefinition = "NUMBER")
    private float pbirate;
    @Column(name = "PHIRATE", columnDefinition = "NUMBER")
    private Float phirate;
    @Nationalized
    @Column(length = 100)
    private String pcprd;
    @Nationalized
    @Column(length = 500)
    private String pelgbl;
    @Nationalized
    @Column(length = 500)
    private String prmthd;
    @Nationalized
    @Column(length = 500)
    private String pprfcrt;
    @Lob
    private String pirinfo;
    @Nationalized
    @Column(length = 100)
    private String pcond;

    @CreationTimestamp
    private LocalDateTime pupdate;

    private String pjnfee;
    @Lob
    private String pterms;
    @Lob
    private String pdirate;
    @Column(length = 500)
    private String psubtitle;
    @Lob
    private String pinfo;

    // 없어서 추가함 - 손진일 2025/11/23
    private String pwtpi;

    public ProductDTO toDTO(){
        return ProductDTO.builder()
                .id(id)
                .pid(pid)
                .ptype(ptype)
                .pname(pname)
                .pbirate(pbirate)
                .phirate(phirate == null ? 0 : phirate)
                .pcprd(pcprd)
                .pelgbl(pelgbl)
                .prmthd(prmthd)
                .pprfcrt(pprfcrt)
                .pirinfo(pirinfo)
                .pcond(pcond)
                .pupdate(pupdate.toString())
                .pjnfee(pjnfee)
                .pterms(pterms)
                .pdirate(pdirate)
                .psubtitle(psubtitle)
                .pinfo(pinfo)
                .pwtpi(pwtpi)
                .build();
    }
}

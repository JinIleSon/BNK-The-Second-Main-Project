package kr.co.bnkfirst.dto.product;

import kr.co.bnkfirst.entity.product.Product;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
public class ProductDTO {
    private int id;
    private String pid;
    private String ptype;
    private String pname;
    private float pbirate;
    private float phirate;
    private String pcprd;
    private String pelgbl;
    private String prmthd;
    private String pprfcrt;
    private String pirinfo;
    private String pcond;
    private String pupdate;
    private String pjnfee;
    private String pterms;
    private String pdirate;
    private String psubtitle;
    private String pinfo;

    // 없어서 추가함 - 손진일 2025/11/23
    private String pwtpi;

    public Product toEntity(){
        return Product.builder()
                .id(id)
                .pid(pid)
                .ptype(ptype)
                .pname(pname)
                .pbirate(pbirate)
                .phirate(phirate)
                .pcprd(pcprd)
                .pelgbl(pelgbl)
                .pprfcrt(pprfcrt)
                .pirinfo(pirinfo)
                .pcond(pcond)
                .pjnfee(pjnfee)
                .pterms(pterms)
                .pdirate(pdirate)
                .psubtitle(psubtitle)
                .pinfo(pinfo)
                .pwtpi(pwtpi)
                .build();
    }
}

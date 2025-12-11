package kr.co.bnkfirst.kiwoomETF;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class EtfDTO {

    private String pcuid;
    private Integer pstock;
    private Integer pprice;
    private Integer psum;
    private String pname;
    private String pacc;
}

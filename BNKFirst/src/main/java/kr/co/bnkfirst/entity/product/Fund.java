package kr.co.bnkfirst.entity.product;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "fund")
public class Fund {

    @Id
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

}

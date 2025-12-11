package kr.co.bnkfirst.dbstock;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class MinuteCandleDTO {

    @JsonProperty("Hour")
    private String Hour;

    @JsonProperty("Date")
    private String Date;

    @JsonProperty("Prpr")
    private String Prpr;     // 현재가

    @JsonProperty("Oprc")
    private String Oprc;     // 시가

    @JsonProperty("Hprc")
    private String Hprc;     // 고가

    @JsonProperty("Lprc")
    private String Lprc;     // 저가

    @JsonProperty("CntgVol")
    private String CntgVol;  // 거래량
}

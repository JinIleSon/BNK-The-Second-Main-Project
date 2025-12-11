package kr.co.bnkfirst.dbstock;

import lombok.Data;

import java.util.List;

@Data
public class DbMinuteChartResponse {
    private List<MinuteCandleDTO> Out;
    private String rsp_cd;
    private String rsp_msg;
}

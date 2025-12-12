package kr.co.bnkfirst.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MainEventDTO {

    private int EVID;
    private String EVTITLE;
    private String EVCONTENT;
    private String EVWRITER;
    private String EVREGDATE;

}

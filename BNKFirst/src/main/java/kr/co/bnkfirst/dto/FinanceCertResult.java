package kr.co.bnkfirst.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FinanceCertResult {
    /*
        날짜 : 2025/11/20
        이름 : 이준우
        내용 : 금융인증서 관련 DTO생성
     */

    // 금융인증서 결과용
    private String name;
    private String birth;
    private String gender;
    private String carrier;
    private String phone;
    private String ci;
}

package kr.co.bnkfirst.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.springframework.stereotype.Component;
import org.springframework.web.context.annotation.SessionScope;

@Setter
@Getter
@Data
@Component
@SessionScope
public class VerificationDTO {

    // 이메일
    private String code;
    private long codeTimestamp;
    private boolean verified = false;

    // SMS 코드
    private String smsCode;
    private Long smsCodeTimestamp;
    private boolean smsVerified = false;
}

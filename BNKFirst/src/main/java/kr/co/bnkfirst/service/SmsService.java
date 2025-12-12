package kr.co.bnkfirst.service;

import com.solapi.sdk.SolapiClient;
import com.solapi.sdk.message.dto.response.MultipleDetailMessageSentResponse;
import com.solapi.sdk.message.model.Message;
import com.solapi.sdk.message.service.DefaultMessageService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import java.util.Random;

@Service
@ConditionalOnProperty(prefix = "solapi", name = "enabled", havingValue = "true", matchIfMissing = false)
public class SmsService {

    @Value("${solapi.api.key}")
    private String apiKey;

    @Value("${solapi.api.secret}")
    private String apiSecret;

    @Value("${solapi.api.number}")
    private String fromNumber;

    @Value("${solapi.mock:true}")
    private boolean mockMode;

    private String lastCode;

    /**
     * 인증번호 생성 + 발송
     */
    public String sendVerificationCode(String phoneNumber) {
        String code = generateVerificationCode();
        lastCode = code;

        if (mockMode) {
            // ✅ MOCK 모드: 콘솔에만 출력
            System.out.println("📱 [MOCK SMS] 발송 대상: " + phoneNumber + ", 인증번호: " + code);
        } else {
            try {
                // ===============================
                // ✅ 실제 Solapi 발송 로직 (필요 시 주석 해제)
                // ===============================

                DefaultMessageService messageService =
                        SolapiClient.INSTANCE.createInstance(apiKey, apiSecret);

                Message message = new Message();
                message.setTo(phoneNumber);
                message.setFrom(fromNumber);
                message.setText("[BNK 부산은행] 본인확인 인증번호는 [" + code + "]입니다. 타인에게 공유하지 마세요.");

                MultipleDetailMessageSentResponse response = messageService.send(message);
                System.out.println("✅ SMS Response: " + response);

            } catch (Exception e) {
                System.err.println("🚨 Solapi SMS 전송 실패: " + e.getMessage());
            }
        }

        return code;
    }

    /**
     * 인증번호 검증
     */
    public boolean verifyCode(String inputCode) {
        return lastCode != null && lastCode.equals(inputCode);
    }

    private String generateVerificationCode() {
        return String.valueOf(new Random().nextInt(900000) + 100000);
    }
}
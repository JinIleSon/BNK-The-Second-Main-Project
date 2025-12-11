package kr.co.bnkfirst.service;

import jakarta.mail.Message;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import kr.co.bnkfirst.dto.VerificationDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.util.concurrent.ThreadLocalRandom;

@Slf4j
@RequiredArgsConstructor
@Service
@Profile("!test")
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String sender;

    private final VerificationDTO sessionData;

    public void sendCode(String receiver) {
        log.info(">>> EmailService.sendCode called, receiver={}", receiver);

        MimeMessage message = mailSender.createMimeMessage();

        int code = ThreadLocalRandom.current().nextInt(100000, 1_000_000);
        String codeStr = String.valueOf(code);

        String title = "본인확인을 위한 이메일 인증번호입니다\n";
        String content =
                "<p>안녕하세요, <b>[BNK] 부산은행</b> 입니다.</p>" +
                        "<p>회원가입을 위한 이메일 인증번호를 안내드립니다.<br>" +
                        "아래의 인증번호를 입력하여 인증을 완료해주세요.</p>" +
                        "<p>인증번호: <strong style='font-size:18px;'>" + code + "</strong></p>" +
                        "<p>감사합니다.</p>";
        try {
            message.setFrom(new InternetAddress(sender, "[BNK] 부산은행", StandardCharsets.UTF_8.name()));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(receiver));
            message.setSubject(title, "UTF-8");
            message.setContent(content, "text/html;charset=UTF-8");

            mailSender.send(message);

            log.info(">>> EmailService: mail sent to {}", receiver);

            sessionData.setCode(codeStr);
            sessionData.setCodeTimestamp(System.currentTimeMillis());
            sessionData.setVerified(false);

        } catch (Exception e) {
            log.error(">>> EmailService: email send failed to {} - {}", receiver, e.getMessage(), e);
            throw new RuntimeException("메일 전송 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
    }

    public boolean verifyCode(String code) {
        log.info(">>> EmailService.verifyCode called, inputCode={}", code);

        String sessCode = sessionData.getCode();

        if (sessCode == null) {
            log.warn(">>> EmailService.verifyCode: no code in session");
            return false;
        }

        boolean matched = sessCode.equals(code);

        if (matched) {
            sessionData.setVerified(true);
            log.info(">>> EmailService.verifyCode: code matched → verified=true");
        } else {
            log.info(">>> EmailService.verifyCode: NOT matched (session={}, input={})", sessCode, code);
        }

        return matched;
    }

}

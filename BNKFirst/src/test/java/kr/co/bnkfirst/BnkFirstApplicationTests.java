package kr.co.bnkfirst;

import kr.co.bnkfirst.fx.KoreaEximFxClient;
import kr.co.bnkfirst.mapper.AdminMapper;
import kr.co.bnkfirst.mapper.BranchMapper;
import kr.co.bnkfirst.mapper.DocumentMapper;
import kr.co.bnkfirst.service.EmailService;
import kr.co.bnkfirst.service.SmsService;
import org.junit.jupiter.api.Test;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@SpringBootTest
@MapperScan("kr.co.bnkfirst.mapper")
class BnkFirstApplicationTests {
    @Test
    void contextLoads() {
    }

    @MockitoBean
    EmailService emailService;
    @MockitoBean
    SmsService smsService;
    @MockitoBean
    KoreaEximFxClient koreaEximFxClient;
}

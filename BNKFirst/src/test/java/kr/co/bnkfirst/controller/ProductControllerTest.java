package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.product.SlfcertDTO;
import kr.co.bnkfirst.entity.product.Slfcert;
import kr.co.bnkfirst.fx.KoreaEximFxClient;
import kr.co.bnkfirst.mapper.*;
import kr.co.bnkfirst.repository.product.SlfcertRepository;
import kr.co.bnkfirst.service.EmailService;
import kr.co.bnkfirst.service.ProductService;
import kr.co.bnkfirst.service.SlfcertService;
import kr.co.bnkfirst.service.SmsService;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.security.Principal;

/*
    날짜 : 2025.11.21.
    이름 : 강민철
    내용 : 상품 페이지 컨트롤러 테스트
 */

@SpringBootTest
class ProductControllerTest {

    @Autowired
    ProductController productController;
    @Autowired
    SlfcertRepository slfcertRepository;
    @MockitoBean
    ProductService productService;
    @Autowired
    SlfcertService slfcertService;
    @MockitoBean
    EmailService emailService;
    @MockitoBean
    SmsService smsService;
    @MockitoBean
    KoreaEximFxClient koreaEximFxClient;

    @Test
    void slfcertForm() {
        SlfcertDTO dummy = SlfcertDTO.builder()
                .cusid("a123")
                .ftype("W9")
                .sts("VALID")
                .taxyr(2025)
                .krres("Y")
                .others("Y")
                .natcd("US")
                .name("홍길동")
                .gender("M")
                .brthdt("1999-01-12")
                .zipcd("12345")
                .addr1("경기 성남시")
                .addr2("")
                .enlnm("HONG")
                .enfnm("GILDONG")
                .phone("010-1111-2222")
                .build();
        Principal principal = Mockito.mock(Principal.class);
        Mockito.when(principal.getName()).thenReturn("a123");
        Slfcert saved = slfcertRepository.save(dummy.toEntity());
        System.out.println("saved = "+saved);
        SlfcertDTO savedDTO = slfcertService.saveSlfcert(dummy);
        System.out.println("savedDTO = "+savedDTO);
        ResponseEntity<SlfcertDTO> savedREntity = productController.slfcertForm(dummy, principal);
        System.out.println("savedREntity = "+savedREntity);
    }
}
package kr.co.bnkfirst.repository.product;

import kr.co.bnkfirst.entity.product.Product;
import kr.co.bnkfirst.fx.KoreaEximFxClient;
import kr.co.bnkfirst.service.EmailService;
import kr.co.bnkfirst.service.SmsService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import javax.sql.DataSource;

@SpringBootTest
class ProductRepositoryTest {
    @Autowired
    ProductRepository productRepository;

    @MockitoBean
    EmailService emailService;
    @MockitoBean
    SmsService smsService;
    @MockitoBean
    KoreaEximFxClient koreaEximFxClient;

    @Test
    void findTest() {
        Pageable pageable = PageRequest.of(1, 6, Sort.by("phirate").descending());
        Page<Product> products = productRepository.findDynamicProducts("개인", null, null, pageable);
        System.out.println(products.map(Product::toDTO).getContent());
    }

    @Autowired
    DataSource ds;

    @Test
    void checkDb() throws Exception {
        System.out.println("URL = " + ds.getConnection().getMetaData().getURL());
        System.out.println("USER = " + ds.getConnection().getMetaData().getUserName());
        System.out.println("COUNT = " + productRepository.count());

        // A. 전체 데이터 보이는지
        var page1 = productRepository.findDynamicProducts(null, null, null, PageRequest.of(0, 10));
        System.out.println(page1.getContent()); // 비어있으면 DB연결/스키마 이슈

        // B. pelgbl만 필터
        var page2 = productRepository.findDynamicProducts("개인", null, null, PageRequest.of(0, 6));
        System.out.println(page2.getContent()); // A OK, B 빈값 → 값/타입/공백 이슈

    }

}
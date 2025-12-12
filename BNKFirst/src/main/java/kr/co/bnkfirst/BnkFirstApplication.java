package kr.co.bnkfirst;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
// 개인 컴퓨터 환경에서 Kiwoom 실행에서 제외
//@ComponentScan(excludeFilters = {
//        @ComponentScan.Filter(
//                type = FilterType.REGEX,
//                pattern = {
//                        "kr\\.co\\.bnkfirst\\.kiwoom\\..*",
//                        "kr\\.co\\.bnkfirst\\.kiwoomRank\\..*",
//                        "kr\\.co\\.bnkfirst\\.config\\.WebSocketConfig",
//                        "kr\\.co\\.bnkfirst\\.kiwoomETF\\..*"
//                }
//        ),
//        @ComponentScan.Filter(
//                type = FilterType.ASSIGNABLE_TYPE,
//                classes = {
//                        kr.co.bnkfirst.controller.StockController.class,
//                        kr.co.bnkfirst.controller.KiwoomTestController.class,
//                }
//        )
//})
@EnableScheduling
public class BnkFirstApplication {

    public static void main(String[] args) {
        SpringApplication.run(BnkFirstApplication.class, args);
    }

}

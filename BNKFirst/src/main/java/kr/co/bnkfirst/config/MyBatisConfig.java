package kr.co.bnkfirst.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("kr.co.bnkfirst.mapper")
public class MyBatisConfig {
}

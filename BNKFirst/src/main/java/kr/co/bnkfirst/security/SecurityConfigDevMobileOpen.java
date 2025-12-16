package kr.co.bnkfirst.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@Profile("dev")
@Order(0)
public class SecurityConfigDevMobileOpen {

    @Bean
    public SecurityFilterChain devMobileOpen(HttpSecurity http) throws Exception {
        return http
                .securityMatcher("/api/mobile/**")
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth.anyRequest().permitAll())
                .build();
    }
}
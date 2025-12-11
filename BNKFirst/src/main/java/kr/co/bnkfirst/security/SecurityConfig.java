package kr.co.bnkfirst.security;

import kr.co.bnkfirst.jwt.JwtAuthenticationFilter;
import kr.co.bnkfirst.jwt.JwtProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // 2025.11.21 이준우 jwt 로그인 방식으로 수정

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            JwtProvider jwtProvider,
            MyUserDetailsService myUserDetailsService
    ) throws Exception {

        http.httpBasic(b -> b.disable())
                .formLogin(f -> f.disable())
                .sessionManagement(s ->
                        s.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                );

        http.authorizeHttpRequests(auth -> auth
                // KFTC API 완전허용 (중요)
                .requestMatchers("/corporate/**").permitAll()    // ★ 가장 위에 두기 (중요)
                .requestMatchers("/BNK/**").permitAll()
                .requestMatchers("/api/kftc/**").permitAll()

                .requestMatchers(
                        "/", "/css/**", "/js/**", "/images/**",
                        "/components/**", "/upload/**",
                        "/member/**", "/main/**",
                        "/api/kftc/**",    // ⭐ 수정 포인트
                        "/api/**", "/cs/**", "/info/**", "/board/**",
                        "/kiwoom/**", "/docs/**", "/product/**",
                        "/qna/**", "/stock/**", "/tologo/**",
                        "/ws/**", "/retirement-renew/**", "/mypage/calc/**",
                        "/corporate/**","/irp/**","/auth/qr/**"
                ).permitAll()
                .requestMatchers("/mypage/**").hasAnyRole("ADMIN", "USER")
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
        );


        http.addFilterBefore(
                new JwtAuthenticationFilter(jwtProvider, myUserDetailsService),
                UsernamePasswordAuthenticationFilter.class
        );

        http.csrf(c -> c.disable());

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}
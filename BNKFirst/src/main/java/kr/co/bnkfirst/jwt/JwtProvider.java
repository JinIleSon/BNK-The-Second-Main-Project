package kr.co.bnkfirst.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import kr.co.bnkfirst.entity.Users;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
@Slf4j
public class JwtProvider {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.issuer}")
    private String issuer;

    private SecretKey key;

    @PostConstruct
    public void init() {
        key = Keys.hmacShaKeyFor(secret.getBytes());
    }

    // JWT 생성
    public String createToken(Users user, String role) {

        long now = System.currentTimeMillis();
        long expireMs = 1000L * 60 * 60 * 24; // 1일

        log.info(role);

        return Jwts.builder()
                .subject(user.getMid())
                .issuer(issuer)
                .claim("uid", user.getUid())
                .claim("role", role)
                .issuedAt(new Date(now))
                .expiration(new Date(now + expireMs))
                .signWith(key)
                .compact();
    }

    // MID 추출
    public String getMidFromToken(String token) {
        return parseClaims(token).getSubject();
    }

    // ROLE 추출
    public String getRoleFromToken(String token) {
        return parseClaims(token).get("role", String.class);
    }

    // 유효성 검사
    public boolean validateToken(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    // Claims 파싱
    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}

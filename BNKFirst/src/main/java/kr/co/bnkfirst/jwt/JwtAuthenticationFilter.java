package kr.co.bnkfirst.jwt;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import kr.co.bnkfirst.security.MyUserDetailsService;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtProvider jwtProvider;
    private final MyUserDetailsService myUserDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String path = request.getRequestURI();

        // ⭐ 기업뱅킹 화면 접근은 인증 제외
        if (path.startsWith("/corporate/")) {
            filterChain.doFilter(request, response);
            return;
        }

        // ⭐ KFTC API 인증 제외
        if (path.startsWith("/BNK/api/kftc/")) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            String token = (String) request.getSession().getAttribute("jwtToken");

            if (token != null && jwtProvider.validateToken(token)) {

                String mid = jwtProvider.getMidFromToken(token);
                UserDetails userDetails = myUserDetailsService.loadUserByUsername(mid);

                Authentication auth = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );

                SecurityContextHolder.getContext().setAuthentication(auth);
            }

        } catch (Exception ex) {
            logger.error("JWT 필터 오류: " + ex.getMessage());
        }

        filterChain.doFilter(request, response);
    }


    private String resolveToken(HttpServletRequest request) {
        String bearer = request.getHeader("Authorization");
        if (bearer != null && bearer.startsWith("Bearer ")) {
            return bearer.substring(7);
        }
        return null;
    }


    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getRequestURI();

        // ⭐ 기업뱅킹(corporate)은 필터 자체를 아예 적용하지 않음
        if (path.startsWith("/corporate/")) {
            return true;
        }


        // ⭐ KFTC API 인증 제외
        if (path.startsWith("/BNK/api/")) {
            return true;
        }

        return false;
    }
}

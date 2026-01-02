package kr.co.bnkfirst.security;

import kr.co.bnkfirst.mapper.UsersMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;
import jakarta.servlet.http.HttpServletRequest;
import kr.co.bnkfirst.jwt.JwtProvider;

@Component
@RequiredArgsConstructor
public class LoginUidProvider {

    private final UsersMapper usersMapper;
    private final HttpServletRequest request;
    private final JwtProvider jwtProvider;

    public Long optionalUidOrNull() {
        try {
            return requireUid();
        } catch (Exception e) {
            return null;
        }
    }

    public Long requireUid() {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7).trim();
            if (!token.isEmpty()) {
                Long uidFromJwt = jwtProvider.getUidFromToken(token);
                if (uidFromJwt != null) return uidFromJwt;
            }
        }

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "LOGIN_REQUIRED");
        }

        Object principal = auth.getPrincipal();

        if (principal instanceof UserDetails ud) {
            return uidByMidOrThrow(ud.getUsername());
        }

        if (principal instanceof String s) {
            if ("anonymousUser".equalsIgnoreCase(s)) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "LOGIN_REQUIRED");
            }
            return uidByMidOrThrow(s);
        }

        String name = auth.getName();
        if (name == null || name.isBlank() || "anonymousUser".equalsIgnoreCase(name)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "LOGIN_REQUIRED");
        }
        return uidByMidOrThrow(name);
    }

    private Long uidByMidOrThrow(String mid) {
        Long uid = usersMapper.selectUidByMid(mid);
        if (uid == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "LOGIN_USER_NOT_FOUND");
        }
        return uid;
    }
}

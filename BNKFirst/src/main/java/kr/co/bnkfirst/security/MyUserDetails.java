package kr.co.bnkfirst.security;

import kr.co.bnkfirst.entity.Users;
import lombok.Builder;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.util.Collection;
import java.util.List;


@Slf4j
@Data
@Builder
public class MyUserDetails implements UserDetails {

    /*
        날짜 : 2025/11/20
        이름 : 이준우
        내용 : security 관련 내용 추가
     */

    private final Users user;

    // 권한 설정
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {

        String role = user.getRole();

        if(role == null || role.isBlank()){
            role = "USER";
        }

        String authority = "ROLE_" + role.toUpperCase();
        log.info("Authority :" + authority);

        return List.of(new SimpleGrantedAuthority(authority));
    }

    // 인증용 비밀번호
    @Override
    public String getPassword() {
        return user.getMpw();
    }

    // 인증용 아이디
    @Override
    public String getUsername() {
        return user.getMid();
    }

    public int getUid(){
        return user.getUid();
    }

    // 계정 상태
    @Override public boolean isAccountNonExpired() {return true;}
    @Override public boolean isAccountNonLocked() {return true;}
    @Override public boolean isCredentialsNonExpired() {return true;}
    @Override public boolean isEnabled() {return true;}
}

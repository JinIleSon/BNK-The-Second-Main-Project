package kr.co.bnkfirst.security;

import kr.co.bnkfirst.entity.Users;
import kr.co.bnkfirst.repository.UsersRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Slf4j
@RequiredArgsConstructor
@Service
public class MyUserDetailsService implements UserDetailsService {

    /*
        날짜 : 2025/11/20
        이름 : 이준우
        내용 : security 관련 내용 추가
     */

    private final UsersRepository usersRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Users user = usersRepository.findByMid(username)
                .orElseThrow(() -> {
                    log.warn("❌ 사용자 [{}] 를 찾을 수 없습니다.",  username);
                    return new UsernameNotFoundException("User not found" + username);
        });

        log.info("✅ 사용자 [{}] 조회 성공 (uid={})", username, user.getUid());

        return MyUserDetails.builder()
                .user(user)
                .build();
    }
}

package kr.co.bnkfirst.service;

import jakarta.transaction.Transactional;
import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.dto.product.PcontractDTO;
import kr.co.bnkfirst.entity.Users;
import kr.co.bnkfirst.mapper.UsersMapper;
import kr.co.bnkfirst.repository.UsersRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class UsersService {

    private final UsersMapper usersMapper;
    private final PasswordEncoder passwordEncoder;
    private final UsersRepository usersRepository;

    // 로그인
    public UsersDTO login(String mId, String mPw) {
        log.info("Trying to login user: {}", mId);

        UsersDTO user = usersMapper.findByMid(mId);
        if (user == null) {
            log.warn("No user found for ID: {}", mId);
            return null;
        }

        // 암호화된 비밀번호 검증 추가
        String storedPw = user.getMpw();
        boolean matches;

        if (storedPw.startsWith("$2a$") || storedPw.startsWith("$2b$")) {
            matches = passwordEncoder.matches(mPw, storedPw);
        } else {
            // 기존 DB 평문 비밀번호용 (초기데이터 호환)
            matches = mPw.equals(storedPw);
        }

        if (!matches) {
            log.warn("Password mismatch for ID: {}", mId);
            return null;
        }

        log.info("Login success for ID: {}", mId);
        log.info("UsersService 반환값 체크: "+user.toString() );
        return user;
    }

    // 회원가입(info)
    public boolean register(UsersDTO dto) {
        log.info("회원가입 시도: {}", dto.getMid());
        try {
            // 비밀번호 암호화 추가
            String encodedPw = passwordEncoder.encode(dto.getMpw());
            dto.setMpw(encodedPw);

            int result = usersMapper.insertUser(dto);
            return result == 1;
        } catch (Exception e) {
            log.error("회원가입 중 오류 발생", e);
            return false;
        }
    }

    // 아이디 중복확인(info)
    public boolean existsByMid(String mid) {
        return usersMapper.existsByMid(mid) > 0;
    }

    // 가입 후 사용자 다시 조회 (MDATE 가져오기)
    public UsersDTO findByMid(String mid) {
        return usersMapper.findByMid(mid);  // mapper 이미 있으므로 그대로 사용
    }

    // 아이디 찾기(findid)
    public String findIdByPhone(String name, String phone) {
        return usersMapper.findIdByPhone(name, phone);
    }
    public String findIdByEmail(String name, String email) {
        return usersMapper.findIdByEmail(name, email);
    }

    // 비밀번호 찾기(findpw)
    public String resetPasswordByPhone(String mid, String phone) {

        UsersDTO user = usersMapper.findByMidAndPhone(mid, phone);
        if (user == null) return null;

        // 임시 비밀번호 생성
        String tempPw = RandomStringUtils.randomAlphanumeric(10);

        String hashed = passwordEncoder.encode(tempPw);
        usersMapper.updatePassword(mid, hashed);

        return tempPw;
    }
    public String resetPasswordByEmail(String mid, String email) {

        UsersDTO user = usersMapper.findByMidAndEmail(mid, email);
        if (user == null) return null;

        String tempPw = RandomStringUtils.randomAlphanumeric(10);

        String hashed = passwordEncoder.encode(tempPw);
        usersMapper.updatePassword(mid, hashed);

        return tempPw;
    }

    // 비밀번호 변경 내용 추가(이준우 2025.11.26)
    // 현재 비밀번호 검증만 하는 메서드
    public boolean checkCurrentPassword(String mid, String rawPw) {

        if (rawPw == null || rawPw.isBlank()) {
            log.warn("checkCurrentPassword 실패 - rawPw null/blank mid={}", mid);
            return false;
        }

        UsersDTO user = usersMapper.findByMid(mid);
        if (user == null) {
            log.warn("checkCurrentPassword 실패 - 사용자 없음 mid={}", mid);
            return false;
        }

        String storedPw = user.getMpw();
        if (storedPw == null || storedPw.isBlank()) {
            log.warn("checkCurrentPassword 실패 - 저장된 비번 없음 mid={}", mid);
            return false;
        }

        boolean matches;
        if (storedPw.startsWith("$2a$") || storedPw.startsWith("$2b$")) {
            matches = passwordEncoder.matches(rawPw, storedPw);
        } else {
            // 예전 평문 패스워드 호환
            matches = rawPw.equals(storedPw);
        }

        log.info("checkCurrentPassword mid={}, matches={}", mid, matches);
        return matches;
    }

    public boolean changePassword(String mid, String currentPw, String newPw){
        // 파라미터 방어
        if (currentPw == null || currentPw.isBlank()) {
            log.warn("비밀번호 변경 실패 - currentPw null/blank mid={}", mid);
            return false;
        }
        if (newPw == null || newPw.isBlank()) {
            log.warn("비밀번호 변경 실패 - newPw null/blank mid={}", mid);
            return false;
        }

        UsersDTO user = usersMapper.findByMid(mid);
        if (user == null) {
            log.warn("비밀번호 변경 실패 - 사용자 없음 mid={}", mid);
            return false;
        }

        String storedPw = user.getMpw();
        if (storedPw == null || storedPw.isBlank()) {
            log.warn("비밀번호 변경 실패 - DB에 저장된 비밀번호 없음 mid={}", mid);
            return false;
        }

        // 현재 비밀번호 검증
        boolean matches;
        if (storedPw.startsWith("$2a$") || storedPw.startsWith("$2b$")) {
            matches = passwordEncoder.matches(currentPw, storedPw);
        } else {
            // 예전 평문 DB 호환
            matches = currentPw.equals(storedPw);
        }

        if (!matches) {
            log.warn("비밀번호 변경 실패 - 현재 비밀번호 불일치 mid={}", mid);
            return false;
        }

        // 새 비밀번호 암호화 후 업데이트
        String encoded = passwordEncoder.encode(newPw);
        int updated = usersMapper.updateMypagePassword(mid, encoded);
        log.info("비밀번호 변경 성공 mid={}, updated={}", mid, updated);

        return updated == 1;
    }

    @Transactional
    public String openDefaultAccount(String mid) {

        PcontractDTO p = PcontractDTO.builder()
                .pcuid(mid)
                .pcpid("BNK-TD-2")
                .pcnapw("1234")
                .pbalance(0)
                .build();

        usersMapper.insertDefaultAccount(p);

        log.info("계좌 개설 완료 - mid={}, accountNo={}", mid, p.getPacc());

        return p.getPacc();
    }

    public void updateLastAccess(String mid) {
        usersMapper.updateLastAccess(mid);
    }
    @Transactional
    public boolean withdrawUser(String mid, String mpw, String mphone) {

        UsersDTO user = usersMapper.findByMid(mid);
        if (user == null) {
            log.warn("회원탈퇴 실패 - 사용자 없음: {}", mid);
            return false;
        }

        if (!passwordEncoder.matches(mpw, user.getMpw())) {
            log.warn("회원탈퇴 실패 - 비밀번호 불일치: {}", mid);
            return false;
        }

        if (!mphone.equals(user.getMphone())) {
            log.warn("회원탈퇴 실패 - 휴대폰 번호 불일치: {}", mid);
            return false;
        }

        int delP = usersMapper.deletePcontractByMid(mid);
        log.info("회원탈퇴: mid={} PCONTRACT 삭제 rows={}", mid, delP);

        int delU = usersMapper.deleteUserByMid(mid);
        log.info("회원탈퇴: mid={} USERS 삭제 rows={}", mid, delU);

        if (delU == 0) {
            throw new RuntimeException("회원 정보 삭제 실패 (해당 MID 없음): " + mid);
        }

        return true;
    }
}

package kr.co.bnkfirst.mapper;

import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.dto.product.PcontractDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UsersMapper {

    UsersDTO findByMid(@Param("mid") String mid);

    // 정보입력(info) insert
    int insertUser(UsersDTO user);

    // 정보입력(info) 아이디 중복확인
    int existsByMid(@Param("mid") String mid);

    // 아이디 찾기(findid) Phone & Email
    String findIdByPhone(@Param("name") String name, @Param("phone") String phone);
    String findIdByEmail(@Param("name") String name, @Param("email") String email);

    // 비밀번호 찾기(findpw) Phone & Email
    UsersDTO findByMidAndPhone(@Param("mid") String mid, @Param("phone") String phone);
    UsersDTO findByMidAndEmail(@Param("mid") String mid, @Param("email") String email);

    // 임시 비밀번호 발급()
    int updatePassword(@Param("mid") String mid, @Param("mpw") String mpw);

    // 마이페이지 비밀번호 변경
    int updateMypagePassword(@Param("mid") String mid, @Param("mpw") String mpw);

    // 기본 계좌 생성
    void insertDefaultAccount(PcontractDTO dto);

    // 최근 접속 일시 업데이트
    void updateLastAccess(String mid);

    // 회원 탈퇴
    int deletePcontractByMid(@Param("mid") String mid);
    int deleteUserByMid(@Param("mid") String mid);
}

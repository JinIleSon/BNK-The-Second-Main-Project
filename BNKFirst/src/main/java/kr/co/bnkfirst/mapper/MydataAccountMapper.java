package kr.co.bnkfirst.mapper;

import kr.co.bnkfirst.dto.MydataAccountDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface MydataAccountMapper {

    @Select("""
        SELECT *
        FROM MYDATAACCOUNT
        WHERE MID = #{mid}
        ORDER BY MYACCID
    """)
    List<MydataAccountDTO> findByUserId(String userId);

    @Select("""
        SELECT *
        FROM MYDATAACCOUNT
        WHERE MYACCID = #{myaccid}
    """)
    MydataAccountDTO findByAccid(Long myaccid);
}
package kr.co.bnkfirst.mapper;

import kr.co.bnkfirst.dto.product.FundDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface FundMapper {
    @Select("""
        SELECT
            FID,
            FNAME,
            FRLVL,
            FM1PR,
            FM3PR,
            FM6PR,
            FM12PR
            FROM FUND
    """)
    List<FundDTO> findAllFunds();
}

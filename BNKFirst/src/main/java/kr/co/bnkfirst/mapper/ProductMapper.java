package kr.co.bnkfirst.mapper;

import kr.co.bnkfirst.dto.product.FundDTO;
import kr.co.bnkfirst.dto.product.PcontractDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductMapper {

    public PcontractDTO resultPcontract(String mid, String pcpid);
    public List<FundDTO> selectFund();
    public FundDTO selectFundDetail(@Param("fid") String fid);

    // 2025.11.27. 강민철 : 계좌 찾기
    public PcontractDTO selectAllByUidAndType(@Param("pcuid") String pcuid, @Param("type") String type);
    // 2025.11.27. 강민철 : 비밀번호 검증을 위한 계좌 가져오기
    public PcontractDTO selectByAccAndUidAndType(String pacc, String pcuid, String type);
    // 2025.11.27. 강민철 : 구매 상품 등록하기
    public int savePcontract(PcontractDTO pcontract);
    // 2025.11.28. 강민철 : 상품 구매시 구매 금액 인출
    public int drawPcontract(PcontractDTO pcontract);
    // 2025.11.30. 강민철 : 상품 판매시 판매 금액 입금
    public int depositPcontract(PcontractDTO pcontract);
    // 2025.11.30. 강민철 : 상품 일부 매도(판매)하기
    public int partSellPcontract(PcontractDTO pcontract);
    // 2025.11.30. 강민철 : 상품 전부 매도(판매)하기
    public int fullSellPcontract(PcontractDTO pcontract);
    // 2025.11.30. 강민철 : 보유 상품 추가 매수(구매)하기
    public int extraBuyPcontract(PcontractDTO pcontract);
}

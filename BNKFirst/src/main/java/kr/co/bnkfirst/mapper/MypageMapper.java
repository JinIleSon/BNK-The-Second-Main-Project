package kr.co.bnkfirst.mapper;

import kr.co.bnkfirst.dto.DocumentDTO;
import kr.co.bnkfirst.dto.mypage.DealDTO;
import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.dto.product.FundDTO;
import kr.co.bnkfirst.dto.product.PcontractDTO;
import kr.co.bnkfirst.kiwoomETF.EtfDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MypageMapper {
    UsersDTO findById(String mid);
    DealDTO findByDeal(String mid);
    List<FundDTO> findByFund(String mid);
    Integer findByBalance(String mid);
    Integer findByFundBalance(String mid);
    List<PcontractDTO> findByContract(String mid);
    List<PcontractDTO> findByFundContract(String mid);
    List<DocumentDTO> findByDocumentList(String mid);
    void registerDeal(@Param("mid") String mid, @Param("dbalance") int dbalance, @Param("dwho") String dwho);
    void updateContract(@Param("pbalance") int pbalance, @Param("pacc") String pacc);
    PcontractDTO findByOneContract(String pacc);
    List<DealDTO> findByDealList(String mid);
    Integer findBySumPlusDbalance(String mid);
    Integer findBySumMinusDbalance(String mid);
    void updateRecvContract(@Param("pbalance") int pbalance,
                            @Param("pacc") String pacc);
    void deleteContract(@Param("pcuid") String pcuid,
                        @Param("pcpid") String pcpid);

    // ETF 주식 불러오기
    List<PcontractDTO> selectEtf(@Param("pcuid") String pcuid);

    // IRP 계좌만 불러오기
    PcontractDTO findByIRP(@Param("pcuid") String pcuid);

    // 2025.11.28. 강민철 - 변경 상품 목록 가져오기
    List<PcontractDTO> findByUidAndType(String pcuid);
}

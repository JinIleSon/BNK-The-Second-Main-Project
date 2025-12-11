package kr.co.bnkfirst.service;

import jakarta.transaction.Transactional;
import kr.co.bnkfirst.dto.DocumentDTO;
import kr.co.bnkfirst.dto.mypage.DealDTO;
import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.dto.product.FundDTO;
import kr.co.bnkfirst.dto.product.PcontractDTO;
import kr.co.bnkfirst.kiwoomETF.EtfDTO;
import kr.co.bnkfirst.mapper.MypageMapper;
import kr.co.bnkfirst.repository.UsersRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class MypageService{

    final UsersRepository usersRepository;
    final MypageMapper mypageMapper;

    public UsersDTO findById(String mid) {
        return mypageMapper.findById(mid);
    }

    public DealDTO findByDeal(String mid) {
        return mypageMapper.findByDeal(mid);
    }

    public List<FundDTO> findByFund(String mid) { return mypageMapper.findByFund(mid); }

    public List<PcontractDTO> findByContract(String mid) {
        return mypageMapper.findByContract(mid);
    }

    public List<PcontractDTO> findByFundContract(String mid) {
        return mypageMapper.findByFundContract(mid);
    }

    public int findByBalance(String mid) {
        Integer sum = mypageMapper.findByBalance(mid);
        return (sum != null) ? sum : 0;
    }

    public int findByFundBalance(String mid) {
        Integer sum = mypageMapper.findByFundBalance(mid);
        return (sum != null) ? sum : 0;
    }

    public List<DocumentDTO> findByDocumentList(String mid) {
        return mypageMapper.findByDocumentList(mid);
    }

    public void registerDeal(String mid, int dbalance, String dwho){
        mypageMapper.registerDeal(mid,dbalance,dwho);
    }

    public void updateContract(int dbalance, String dwho){
        mypageMapper.updateContract(dbalance,dwho);
    }

    public PcontractDTO findByOneContract(String pacc) {
        return mypageMapper.findByOneContract(pacc);
    }

    @Transactional
    public void transfer(String mid, int dbalance, String dwho, String myAcc, String yourAcc) {
        registerDeal(mid, -dbalance, dwho);
        registerDeal(findByOneContract(yourAcc).getPcuid(), dbalance, findById(mid).getMname());
        updateContract(findByOneContract(myAcc).getPbalance() - dbalance, myAcc);
        updateContract(findByOneContract(yourAcc).getPbalance() + dbalance, yourAcc);
    }

    public List<DealDTO> findByDealList(String mid){
        return mypageMapper.findByDealList(mid);
    }

    public int findBySumPlusDbalance(String mid){
        Integer sum = mypageMapper.findBySumPlusDbalance(mid);
        return (sum != null) ? sum : 0;
    }

    public Integer findBySumMinusDbalance(String mid){
        Integer sum = mypageMapper.findBySumMinusDbalance(mid);
        int result = (sum != null) ? sum : 0;
        return result;
    }

//    상품 해지 과정
    public void updateRecvContract(int pbalance, String pacc) {
        mypageMapper.updateRecvContract(pbalance, pacc);
    }

    public void deleteContract(String pcuid, String pcpid) {
        mypageMapper.deleteContract(pcuid, pcpid);
    }

    @Transactional
    public void deleteContractProcess(int pbalance, String recvAcc, String pcuid, String pcpid) {
        updateRecvContract(pbalance, recvAcc);
        deleteContract(pcuid, pcpid);
    }

    // ETF 주식 불러오기
    public List<PcontractDTO> selectEtf(@Param("pcuid") String pcuid){
        return mypageMapper.selectEtf(pcuid);
    }

    /*
        날짜 : 2025.11.28.
        이름 : 강민철
        내용 : 변경 상품 목록 불러오기
     */
    public List<PcontractDTO> getProdEditList(@Param("pcuid") String pcuid) {
        return mypageMapper.findByUidAndType(pcuid);
    }
}

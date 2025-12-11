package kr.co.bnkfirst.service;

import jakarta.transaction.Transactional;
import kr.co.bnkfirst.dto.product.FundDTO;
import kr.co.bnkfirst.dto.product.PcontractDTO;
import kr.co.bnkfirst.kiwoomETF.EtfDTO;
import kr.co.bnkfirst.mapper.MypageMapper;
import kr.co.bnkfirst.mapper.StockMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.annotations.Param;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class StockService {

    private final MypageMapper mypageMapper;
    private final StockMapper stockMapper;

    public List<PcontractDTO> findByContract(String mid){
        return mypageMapper.findByContract(mid);
    }

    // 주식 구매 프로세스
    public void buyStock(@RequestParam("pcuid") String pcuid,
                         @RequestParam("pstock") Integer pstock,
                         @RequestParam("pprice") Integer pprice,
                         @RequestParam("psum") Integer psum,
                         @RequestParam("pname") String pname,
                         @RequestParam("pacc") String pacc,
                         @RequestParam("code") String code){

        try {
            stockMapper.buyStock(pcuid, pstock, pprice, psum, pname, pacc, code);
        } catch (DataAccessException e) {
            log.error("주식 매수 DB 처리 중 오류 발생. pcuid={}, pacc={}, pname={}",
                    pcuid, pacc, pname, e);
        }
    }

    public void downBalance(@RequestParam("psum") Integer psum,
                            @RequestParam("pacc") String pacc){

        if (psum == null || psum <= 0) {
            throw new IllegalArgumentException("총합(psum)은 1 이상이어야 합니다.");
        }
        if (pacc == null || pacc.isBlank()) {
            throw new IllegalArgumentException("계좌번호(pacc)는 필수입니다.");
        }

        try {
            stockMapper.downBalance(psum, pacc);
        } catch (DataAccessException e) {
            log.error("계좌 잔액 차감 중 DB 오류 발생. pacc={}", pacc, e);
        }
    }

    @Transactional
    public void buyProcess(@RequestParam("pcuid") String pcuid,
                           @RequestParam("pstock") Integer pstock,
                           @RequestParam("pprice") Integer pprice,
                           @RequestParam("psum") Integer psum,
                           @RequestParam("pname") String pname,
                           @RequestParam("pacc") String pacc,
                           @RequestParam("code") String code){

        if (psum == null) {
            psum = pstock * pprice;
        }

        buyStock(pcuid,pstock,pprice,psum,pname,pacc, code);
        downBalance(psum,pacc);
    }

    // 판매할 주식이 있는지 찾음
    public EtfDTO findByStock(@RequestParam("pacc") String pacc,
                                    @RequestParam("pname") String pname){
        if (pacc == null || pacc.isBlank()) {
            pacc = "계좌없음";
        }
        if (pname == null || pname.isBlank()) {
            pname = "종목명없음";
        }
        return stockMapper.findByStock(pacc, pname);
    }

    // 주식 판매 프로세스
    public void upBalance(@RequestParam("psum") Integer psum,
                          @RequestParam("pacc") String pacc){
        if (pacc == null || pacc.isBlank()) {
            throw new IllegalArgumentException("계좌번호(pacc)는 필수입니다.");
        }
        stockMapper.upBalance(psum,pacc);
    }

    public void sellStock(@RequestParam("pname") String pname,
                          @RequestParam("pcuid") String pcuid){
        stockMapper.sellStock(pname,pcuid);
    }

    @Transactional
    public void sellProcess(@RequestParam("psum") Integer psum,
                           @RequestParam("pacc") String pacc,
                           @RequestParam("pname") String pname,
                           @RequestParam("pcuid") String pcuid){


        upBalance(psum,pacc);
        sellStock(pname,pcuid);
    }

    public PcontractDTO findByIRP(@Param("pcuid") String pcuid){
        return mypageMapper.findByIRP(pcuid);
    }
}

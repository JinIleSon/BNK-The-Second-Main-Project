package kr.co.bnkfirst.mapper;

import kr.co.bnkfirst.kiwoomETF.EtfDTO;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.context.annotation.RequestScope;

import java.util.List;

@Mapper
public interface StockMapper {

    // 주식 구매 프로세스
    public void buyStock(@RequestParam("pcuid") String pcuid,
                         @RequestParam("pstock") Integer pstock,
                         @RequestParam("pprice") Integer pprice,
                         @RequestParam("psum") Integer psum,
                         @RequestParam("pname") String pname,
                         @RequestParam("pacc") String pacc,
                         @RequestParam("code") String code);

    public void downBalance(@RequestParam("psum") Integer psum,
                            @RequestParam("pacc") String pacc);
    // 주식 구매 프로세스

    // 주식 찾기 프로세스(판매)
    public EtfDTO findByStock(@RequestParam("pacc") String pacc,
                                    @RequestParam("pname") String pname);

    // 주식 판매 프로세스

    public void upBalance(@RequestParam("psum") Integer psum,
                          @RequestParam("pacc") String pacc);

    public void sellStock(@RequestParam("pname") String pname,
                          @RequestParam("pcuid") String pcuid);

    // 주식 판매 프로세스

}

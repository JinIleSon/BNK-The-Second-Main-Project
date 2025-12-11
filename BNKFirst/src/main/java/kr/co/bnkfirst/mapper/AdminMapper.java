package kr.co.bnkfirst.mapper;

import kr.co.bnkfirst.dto.PFundPageRequestDTO;
import kr.co.bnkfirst.dto.PageRequestDTO;
import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.dto.product.FundDTO;
import kr.co.bnkfirst.dto.product.ProductDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AdminMapper {

    // ========= 예적금(상품) =========
    List<ProductDTO> selectProductPage(@Param("offset") int offset,
                                       @Param("limit") int limit,
                                       @Param("req") PFundPageRequestDTO req);

    int selectProductTotal(@Param("req") PFundPageRequestDTO req);

    // ========= 펀드 =========
    List<FundDTO> selectFundPage(@Param("offset") int offset,
                                 @Param("limit") int limit,
                                 @Param("req") PFundPageRequestDTO req);

    int selectFundTotal(@Param("req") PFundPageRequestDTO req);

    // 예적금 상품 등록
    public void insertDeposit(@Param("pid") String pid,
                              @Param("ptype") String ptype,
                              @Param("pname") String pname,
                              @Param("pbirate") float pbirate,
                              @Param("phirate") float phirate,
                              @Param("pcprd") String pcprd,
                              @Param("pelgbl") String pelgbl,
                              @Param("prmthd") String prmthd,
                              @Param("pprfcrt") String pprfcrt,
                              @Param("pirinfo") String pirinfo,
                              @Param("pcond") String pcond,
                              @Param("pjnfee") String pjnfee,
                              @Param("pwtpi") String pwtpi,
                              @Param("pterms") String pterms,
                              @Param("pdirate") String pdirate,
                              @Param("psubtitle") String psubtitle,
                              @Param("pinfo") String pinfo
                              );

    // 펀드 상품 등록
    public void insertFund(@Param("fid") String fid,
                           @Param("fname") String fname,
                           @Param("famc") String famc,
                           @Param("frlvl") int frlvl,
                           @Param("ftype") String ftype,
                           @Param("frefpr") float frefpr,
                           @Param("fsetdt") String fsetdt,
                           @Param("ftc") float ftc,
                           @Param("fm1pr") float fm1pr,
                           @Param("fm3pr") float fm3pr,
                           @Param("fm6pr") float fm6pr,
                           @Param("fm12pr") float fm12pr,
                           @Param("facmpr") float facmpr
                           );

    // 예적금 상품 조회(수정용)
    public ProductDTO selectByProduct(@Param("pid") String pid);

    // 예적금 상품 수정
    public void updateProduct(@Param("pid") String pid,
                              @Param("ptype") String ptype,
                              @Param("pname") String pname,
                              @Param("pbirate") String pbirate,
                              @Param("phirate") String phirate,
                              @Param("pcprd") String pcprd,
                              @Param("pelgbl") String pelgbl,
                              @Param("prmthd") String prmthd,
                              @Param("pprfcrt") String pprfcrt,
                              @Param("pirinfo") String pirinfo,
                              @Param("pcond") String pcond,
                              @Param("pjnfee") String pjnfee,
                              @Param("pwtpi") String pwtpi,
                              @Param("pterms") String pterms,
                              @Param("pdirate") String pdirate,
                              @Param("psubtitle") String psubtitle,
                              @Param("pinfo") String pinfo
                              );

    // 펀드 상품 조회(수정용)
    public FundDTO selectByFund(@Param("fid") String fid);

    // 펀드 상품 수정
    public void updateFund(@Param("fid") String fid,
                           @Param("fname") String fname,
                           @Param("famc") String famc,
                           @Param("frlvl") String frlvl,
                           @Param("ftype") String ftype,
                           @Param("frefpr") String frefpr,
                           @Param("fsetdt") String fsetdt,
                           @Param("ftc") String ftc,
                           @Param("fm1pr") String fm1pr,
                           @Param("fm3pr") String fm3pr,
                           @Param("fm6pr") String fm6pr,
                           @Param("fm12pr") String fm12pr,
                           @Param("facmpr") String facmpr
    );

    // 예적금 상품 삭제
    public void deleteByProduct(String pid);

    // 펀드 상품 삭제
    public void deleteByFund(String fid);


    // 유저 목록 출력
    public List<UsersDTO> selectAllUsers(@Param("pageRequestDTO") PageRequestDTO pageRequestDTO);
    public int selectCountTotalUsers(@Param("pageRequestDTO") PageRequestDTO pageRequestDTO);

    // 전체회원 수 출력
    public int countAllUsers();
    // 신규가입 수 출력(현재 시간으로부터 6개월까지)
    public int countSixMonthUsers();
    // 상태가 휴면인 회원 수 출력
    public int countWait();
    // 상태가 탈퇴인 회원 수 출력
    public int countWithdrawal();

    // IRP,DC,DB 상품 개수 출력
    public int countByItem(String pelgbl);

    // Fund 상품 개수 출력
    public int countByFund();

    // 막대그래프용 pbirate(IRP, DC, DB)
    public Double avgByItem(String pelgbl);

    // 파이차트용 fund 위험등급 (1~6등급)
    public int countByDanger(int frlvl);

}

package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.PFundPageRequestDTO;
import kr.co.bnkfirst.dto.PageRequestDTO;
import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.dto.admin.AdminProductRowDTO;
import kr.co.bnkfirst.dto.admin.PageResponseAdminProductDTO;
import kr.co.bnkfirst.dto.admin.PageResponseAdminUsersDTO;
import kr.co.bnkfirst.dto.product.FundDTO;
import kr.co.bnkfirst.dto.product.ProductDTO;
import kr.co.bnkfirst.mapper.AdminMapper;
import kr.co.bnkfirst.repository.product.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.annotations.Param;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class AdminService {

    private final ProductRepository productRepository;
    private final ModelMapper modelMapper;

    private final AdminMapper adminMapper;

    // 상품 목록 페이지네이션
    public PageResponseAdminProductDTO selectAllProduct(PFundPageRequestDTO pageRequestDTO) {

        int pageSize   = pageRequestDTO.getSize(); // 화면에 뿌릴 전체 행 수 (예: 10)
        int perType    = pageSize / 2;             // 예적금 5개 + 펀드 5개
        int page       = pageRequestDTO.getPg();

        // 타입별 오프셋은 perType 기준!
        int productOffset = (page - 1) * perType;
        int fundOffset    = (page - 1) * perType;

        // 1) 예적금
        List<ProductDTO> productList =
                adminMapper.selectProductPage(productOffset, perType, pageRequestDTO);
        int productTotal =
                adminMapper.selectProductTotal(pageRequestDTO);

        // 2) 펀드
        List<FundDTO> fundList =
                adminMapper.selectFundPage(fundOffset, perType, pageRequestDTO);
        int fundTotal =
                adminMapper.selectFundTotal(pageRequestDTO);

        // 3) 화면용 Row로 합치기
        List<AdminProductRowDTO> rows = new ArrayList<>();
        productList.forEach(p -> rows.add(AdminProductRowDTO.from(p)));
        fundList.forEach(f -> rows.add(AdminProductRowDTO.from(f)));

        // 4) 전체 페이지 수 계산(예적금/펀드 각각 필요 페이지 중 더 큰 값)
        int productPages = (int) Math.ceil(productTotal / (double) perType);
        int fundPages    = (int) Math.ceil(fundTotal    / (double) perType);
        int totalPages   = Math.max(productPages, fundPages);

        // PageResponseAdminProductDTO는 total/size로 last를 계산하니까,
        // last가 totalPages가 되도록 "가상의 total"을 만들어서 넘겨줌
        int virtualTotal = totalPages * pageSize;

        return PageResponseAdminProductDTO.builder()
                .pageRequestDTO(pageRequestDTO)
                .dtoList(rows)
                .total(virtualTotal)   // 진짜 개수(12)가 아니라 페이징용 가상 값
                .build();
    }
    // 예적금 상품 추가
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
                              @Param("pinfo") String pinfo) {
        adminMapper.insertDeposit(pid, ptype, pname, pbirate, phirate, pcprd, pelgbl,
                prmthd, pprfcrt, pirinfo, pcond, pjnfee, pwtpi, pterms, pdirate, psubtitle, pinfo);
    }

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
                           @Param("facmpr") float facmpr){
        adminMapper.insertFund(fid, fname, famc, frlvl, ftype, frefpr, fsetdt, ftc, fm1pr, fm3pr, fm6pr, fm12pr, facmpr);
    }

    // 예적금 상품 조회(수정용)
    public ProductDTO selectByProduct(@Param("pid") String pid){
        return adminMapper.selectByProduct(pid);
    }

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
                              @Param("pinfo") String pinfo){
        adminMapper.updateProduct(pid, ptype, pname, pbirate, phirate, pcprd, pelgbl, prmthd, pprfcrt, pirinfo, pcond, pjnfee, pwtpi, pterms, pdirate, psubtitle, pinfo);
    }

    // 펀드 상품 조회(수정용)
    public FundDTO selectByFund(@Param("fid") String fid){
        return adminMapper.selectByFund(fid);
    }

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
                           @Param("facmpr") String facmpr){
        adminMapper.updateFund(fid, fname, famc, frlvl, ftype, frefpr, fsetdt, ftc, fm1pr, fm3pr, fm6pr, fm12pr, facmpr);
    }

    // 예적금 상품 삭제
    public void deleteByProduct(String pid) {
        adminMapper.deleteByProduct(pid);
    }

    // 펀드 상품 삭제
    public void deleteByFund(String fid) {
        adminMapper.deleteByFund(fid);
    }

    // 유저 목록 페이지네이션
    public PageResponseAdminUsersDTO selectAllUsers(PageRequestDTO pageRequestDTO) {
        // MyBatis 처리
        List<UsersDTO> dtoList = adminMapper.selectAllUsers(pageRequestDTO);

        int total = adminMapper.selectCountTotalUsers(pageRequestDTO);

        return PageResponseAdminUsersDTO.builder()
                .pageRequestDTO(pageRequestDTO)
                .dtoList(dtoList)
                .total(total)
                .build();
    }

    public int selectCountTotalUsers(PageRequestDTO pageRequestDTO) {
        return adminMapper.selectCountTotalUsers(pageRequestDTO);
    }





    // 전체회원 수 출력
    public int countAllUsers(){
        return adminMapper.countAllUsers();
    };
    // 신규가입 수 출력(현재 시간으로부터 6개월까지)
    public int countSixMonthUsers(){
        return adminMapper.countSixMonthUsers();
    };
    // 상태가 휴면인 회원 수 출력
    public int countWait(){
        return adminMapper.countWait();
    };
    // 상태가 탈퇴인 회원 수 출력
    public int countWithdrawal(){
        return adminMapper.countWithdrawal();
    };

    // IRP,DC,DB 상품 개수 출력
    public int countByItem(String pelgbl){
        return adminMapper.countByItem(pelgbl);
    };

    // Fund 상품 개수 출력
    public int countByFund(){
        return adminMapper.countByFund();
    }

    // 막대그래프용 pbirate(IRP, DC, DB)
    public Double avgByItem(String pelgbl){
        return adminMapper.avgByItem(pelgbl);
    };

    // 파이차트용 fund 위험등급 (1~6등급)
    public int countByDanger(int frlvl){
        return adminMapper.countByDanger(frlvl);
    };

}
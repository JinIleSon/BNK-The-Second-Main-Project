package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.mypage.EditRequestDTO;
import kr.co.bnkfirst.dto.product.FundDTO;
import kr.co.bnkfirst.dto.product.PcontractDTO;
import kr.co.bnkfirst.dto.product.ProductDTO;
import kr.co.bnkfirst.entity.product.Product;
import kr.co.bnkfirst.mapper.FundMapper;
import kr.co.bnkfirst.mapper.ProductMapper;
import kr.co.bnkfirst.repository.product.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductService {
    private final ProductRepository productRepository;
    private final ProductMapper productMapper;
//    private static final List<String> ORDER_JOIN   = List.of("인터넷", "영업점", "스마트폰");
//    private static final Set<String>  ALLOWED_JOIN = Set.copyOf(ORDER_JOIN);
//
//    private static final List<String> ORDER_TARGET   = List.of("개인", "기업", "개인사업자");  // 예시
//    private static final Set<String>  ALLOWED_TARGET = Set.copyOf(ORDER_TARGET);
//
//    private static final List<String> ORDER_TAX   = List.of("비과세", "세금우대", "소득공제"); // 예시
//    private static final Set<String>  ALLOWED_TAX = Set.copyOf(ORDER_TAX);

//    private static final List<String> ORDER_TAX   = List.of("비과세", "세금우대", "소득공제"); // 예시
//    private static final Set<String>  ALLOWED_TAX = Set.copyOf(ORDER_TAX);

    private final FundMapper fundMapper;

//    public static String normalizeMulti(String raw, List<String> order, Set<String> allowed) {
//        if (raw == null || raw.isBlank()) return null; // 필터 미적용
//        return Arrays.stream(raw.split("\\s*,\\s*"))     // 쉼표 기준, 양옆 공백 무시
//                .map(String::trim)
//                .filter(s -> !s.isBlank() && allowed.contains(s)) // 허용값만
//                .distinct()                                      // 중복 제거
//                .sorted(Comparator.comparingInt(order::indexOf)) // 고정 순서
//                .collect(Collectors.joining(","));
//    }

    public Page<ProductDTO> findProducts(Pageable pageable,
                                         String target,
                                         String join,
                                         String keyword) {
        Page<Product> products = null;
        products = productRepository.findPrefSorted(keyword, target, join, pageable);
        log.info("products = {}", products);
        return products.map(Product::toDTO);
    }

    @Transactional(readOnly = true) // 조회 전용이라는 힌트를 DB/JPA/Spring에게 주는 어노테이션
    public Optional<ProductDTO> findProductByPid(String pid) {
        if (pid == null || pid.isBlank()) return Optional.empty();
        return productRepository.findByPid(pid).map(Product::toDTO);
    }

    public PcontractDTO resultPcontract(String mid, String pcpid){
        return productMapper.resultPcontract(mid, pcpid);
    }
    @Transactional(readOnly = true)
    public List<ProductDTO> searchProducts(String keyword) {
        List<Product> products = productRepository
                .findByPnameContainingIgnoreCaseOrPtypeContainingIgnoreCase(keyword, keyword);

        // 콘솔 로그로 확인
        log.info("[DB 조회 완료] keyword='{}', 결과 {}건", keyword, products.size());

        return products.stream()
                .map(Product::toDTO)
                .collect(Collectors.toList());
    }

    //퇴직연금 상품 목록 조회 메소드 추가 - 세현
    public List<ProductDTO> findRetireProducts() {
        List<Product> list = productRepository.findByPtype("퇴직연금");
        return list.stream()
                .map(Product::toDTO)
                .collect(Collectors.toList());
    }

    public List<FundDTO> selectFund(){
        return productMapper.selectFund();
    }

    // 펀드 목록 + 페이징
    @Transactional(readOnly = true)
    public Page<FundDTO> findFunds(Pageable pageable,
                                   String operator,
                                   String grade,
                                   String type,
                                   String channel,
                                   String keyword) {

        // 1) 전체 펀드 가져오기 (MyBatis)
        List<FundDTO> list = productMapper.selectFund();

        // 2) 키워드(상품명) 필터
        if (keyword != null && !keyword.isBlank()) {
            String kw = keyword.trim().toLowerCase();
            list = list.stream()
                    .filter(f -> f.getFname() != null &&
                            f.getFname().toLowerCase().contains(kw))
                    .toList();
        }

        // 3) 운용사 필터 : famc 기준
        if (operator != null && !operator.isBlank()) {
            Set<String> ops = Arrays.stream(operator.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toSet());

            list = list.stream()
                    .filter(f -> f.getFamc() != null && ops.contains(f.getFamc()))
                    .toList();
        }

        // 4) 위험등급 필터 (grade=1,2,...)
// frlvl 이 int 라는 가정 (FundDTO의 frlvl 타입이 int 맞음)
        if (grade != null && !grade.isBlank()) {
            Set<Integer> grades = Arrays.stream(grade.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(Integer::parseInt)
                    .collect(Collectors.toSet());

            list = list.stream()
                    .filter(f -> grades.contains(f.getFrlvl()))
                    .toList();
        }

        // 5) 펀드유형 필터 (type=채권형,주식형,...)
        if (type != null && !type.isBlank()) {
            Set<String> types = Arrays.stream(type.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toSet());

            list = list.stream()
                    .filter(f -> f.getFtype() != null && types.contains(f.getFtype()))
                    .toList();
        }

        // 6) 채널구분 필터 (channel=온라인전용 ...)
        // FundDTO 에 대응 필드가 있으면 거기에 맞춰서 바꿔줘.
        // 예: evaltype 이 채널이라면 이렇게:
        if (channel != null && !channel.isBlank()) {
            Set<String> chs = Arrays.stream(channel.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toSet());

            list = list.stream()
                    .filter(f -> f.getEvaltype() != null && chs.contains(f.getEvaltype()))
                    .toList();
        }

        // 7) 페이징 적용
        int start = (int) pageable.getOffset();
        int end   = Math.min(start + pageable.getPageSize(), list.size());

        List<FundDTO> content =
                (start >= list.size()) ? Collections.emptyList() : list.subList(start, end);

        return new PageImpl<>(content, pageable, list.size());
    }

    // 작업자: 전세현
    // 내용 : 마이데이터 수익률 계산
    public List<Map<String,Object>> findBetterProducts(Double foreignRate,String risk){

        List<Map<String,Object>> result = new ArrayList<>();

        /* ---------- FUND ---------- */
        if (!"deposit".equals(risk)) {
            /*fund 테이블 평균 수익률 계산*/
            List<FundDTO> funds = fundMapper.findAllFunds();

            for(FundDTO f : funds){

                Double avg = avgFundRate(f);

                if (avg == null) continue;

                // 위험도 필터 적용
                if(risk != null && avg > foreignRate){
                    if(!matchRisk(f.getFrlvl(),risk)) continue;
                }

                if(avg > foreignRate){
                    Map<String,Object> m = new HashMap<>();
                    m.put("type","FUND");
                    m.put("name",f.getFname());
                    m.put("rate",avg.doubleValue()); //Double 통일
                    m.put("id",f.getFid());

                    result.add(m);
                }
            }
        }

        /* ---------- PRODUCT(예금) ---------- */
        if ("deposit".equals(risk)) {
            /*product 테이블 pbirate 비교*/
            List<Product> products = productRepository.findAll();

            for(Product p: products){
                if(p.getPbirate() > foreignRate){
                    Map<String,Object> m = new HashMap<>();
                    m.put("type","PRODUCT");
                    m.put("name",p.getPname());
                    m.put("rate",Double.valueOf(p.getPbirate())); // float -> Double 변환
                    m.put("id",p.getPid());

                    result.add(m);
                }
            }
        }

        /* ---------- 정렬 + 상위 3개 ---------- */
        /*rate 기준 내림차순 정렬 후 상위 3개만 반환*/
        return result.stream()
                .sorted((a, b) -> Double.compare((Double)b.get("rate"), (Double)a.get("rate")))
                .limit(3)
                .toList();
    }

    /* ---------- 펀드 : 평균 금리 구하는 함수 ---------- */
    private Double avgFundRate(FundDTO f){
        List<Double> rates = new ArrayList<>();

        if (f.getFm1pr() != 0) rates.add((double) f.getFm1pr());
        if (f.getFm3pr() != 0) rates.add((double) f.getFm3pr());
        if (f.getFm6pr() != 0) rates.add((double) f.getFm6pr());
        if (f.getFm12pr() != 0) rates.add((double) f.getFm12pr());

        if (rates.isEmpty()) return null;

        return rates.stream().mapToDouble(Double::doubleValue).average().orElse(0.0);
    }

    /* ---------- 위험도 필터링 함수 ---------- */
    private boolean matchRisk(int frlvl, String risk) {
        return switch (risk){
            case "low"  -> frlvl == 5 || frlvl == 6;
            case "mid"  -> frlvl == 3 || frlvl == 4;
            case "high" -> frlvl == 1 || frlvl == 2;
            default -> false;
        };
    }


    public FundDTO getFundDetail(String fid) {
        return productMapper.selectFundDetail(fid);
    }


    /*
        날짜 : 2025.11.27.
        이름 : 강민철
        내용 : 계좌 가져오기
     */
    public PcontractDTO getAccount(String pcuid, String type) {
        return productMapper.selectAllByUidAndType(pcuid, type);
    }

    /*
        날짜 : 2025.11.27.
        이름 : 강민철
        내용 : 계좌 비밀번호 검증
     */
    public boolean checkAccPin(String pacc, String pin, String mid, String type) {
        PcontractDTO acc = productMapper.selectByAccAndUidAndType(pacc, mid, type);
        log.info("accDTO: {}", acc);
        log.info("accPin: {}", acc.getPcnapw());
        log.info("pin: {}", pin);
        log.info("check: {}", pin.equals(acc.getPcnapw()));
        return pin.equals(acc.getPcnapw());
    }

    /*
        날짜 : 2025.11.27.
        이름 : 강민철
        내용 : 원리금 보장상품(예적금) 매수 등록
     */
    @Transactional
    public boolean buyProduct(String pcuid,PcontractDTO pc){
        pc.setPcuid(pcuid);
        int count = productMapper.savePcontract(pc);
        log.info("count: {}", count);
        if (count > 0)
            productMapper.drawPcontract(pc);
        return count > 0;
    }
    
    /*
        날짜 : 2025.11.30.
        이름 : 강민철
        내용 : 변경 상품 매도
     */
    @Transactional
    public boolean editSellProduct(String pcuid, String pacc, EditRequestDTO editRequestDTO) {
        List<String> sellTypes =  editRequestDTO.getSellTypes();
        List<PcontractDTO> pcList = editRequestDTO.getProducts();

        if (sellTypes.size() != pcList.size()) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return false;
        }

        PcontractDTO depositDTO = PcontractDTO.builder()
                .pcuid(pcuid)
                .pacc(pacc)
                .pbalance(editRequestDTO.getTotalAmount().intValue())
                .type("IRP")
                .build();
        int checkError = 0;

        checkError = productMapper.depositPcontract(depositDTO);
        if(checkError == 0) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return false;
        }

        for (int i = 0; i < sellTypes.size(); i++) {
            pcList.get(i).setPcuid(pcuid);
            if (sellTypes.get(i).equals("PART")) {
                checkError = productMapper.partSellPcontract(pcList.get(i));
            } else if (sellTypes.get(i).equals("FULL")) {
                checkError = productMapper.fullSellPcontract(pcList.get(i));
            } else {
                TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                return false;
            }
            if (checkError < 1) {
                TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                return false;
            }
        }

        return true;
    }

    /*
        날짜 : 2025.11.30.
        이름 : 강민철
        내용 : 변경 상품 매수S
     */
    @Transactional
    public boolean editBuyProduct(String pcuid, String pacc, EditRequestDTO editRequestDTO) {
        List<PcontractDTO> pcList = editRequestDTO.getProducts();
        PcontractDTO drawDTO = PcontractDTO.builder()
                .pcuid(pcuid)
                .pacc(pacc)
                .pbalance(editRequestDTO.getTotalAmount().intValue())
                .type("IRP")
                .build();
        int checkError = 0;

        checkError = productMapper.drawPcontract(drawDTO);
        if(checkError == 0) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return false;
        }

        for (int i = 0; i < pcList.size(); i++) {
            pcList.get(i).setPcuid(pcuid);
            checkError = productMapper.extraBuyPcontract(pcList.get(i));
            if (checkError < 1) {
                TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                return false;
            }
        }

        return true;
    }
}
package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.BranchDTO;
import kr.co.bnkfirst.dto.DocumentDTO;
import kr.co.bnkfirst.dto.PFundPageRequestDTO;
import kr.co.bnkfirst.dto.PageRequestDTO;
import kr.co.bnkfirst.dto.admin.PageResponseAdminDocumentDTO;
import kr.co.bnkfirst.dto.admin.PageResponseAdminProductDTO;
import kr.co.bnkfirst.dto.admin.PageResponseAdminUsersDTO;
import kr.co.bnkfirst.dto.product.FundDTO;
import kr.co.bnkfirst.dto.product.ProductDTO;
import kr.co.bnkfirst.service.AdminService;
import kr.co.bnkfirst.service.BranchService;
import kr.co.bnkfirst.service.DocumentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Slf4j
@Controller
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;
    private final DocumentService documentService;
    private final BranchService branchService;


    @GetMapping("/admin/main")
    public String main(Model model){

        model.addAttribute("IRP", adminService.countByItem("IRP"));
        model.addAttribute("DC", adminService.countByItem("DC"));
        model.addAttribute("DB", adminService.countByItem("DB"));
        model.addAttribute("Fund", adminService.countByFund());

        model.addAttribute("pbIRP", adminService.avgByItem("IRP"));
        model.addAttribute("pbDC", adminService.avgByItem("DC"));
        model.addAttribute("pbDB", adminService.avgByItem("DB"));

        model.addAttribute("Danger1Fund", adminService.countByDanger(1));
        model.addAttribute("Danger2Fund", adminService.countByDanger(2));
        model.addAttribute("Danger3Fund", adminService.countByDanger(3));
        model.addAttribute("Danger4Fund", adminService.countByDanger(4));
        model.addAttribute("Danger5Fund", adminService.countByDanger(5));
        model.addAttribute("Danger6Fund", adminService.countByDanger(6));

        return "admin/admin_main";
    }
    @GetMapping("/admin/member")
    public String member(Model model, PageRequestDTO pageRequestDTO){

        log.info("pageRequestDTO={}", pageRequestDTO);
        PageResponseAdminUsersDTO pageResponseDTO = adminService.selectAllUsers(pageRequestDTO);

        model.addAttribute("pageResponseDTO", pageResponseDTO);

        // 전체회원 수 출력
        model.addAttribute("countAllUsers", adminService.countAllUsers());
        // 신규가입 수 출력(현재 시간으로부터 6개월까지)
        model.addAttribute("countSixMonthUsers", adminService.countSixMonthUsers());
        // 상태가 휴면인 회원 수 출력
        model.addAttribute("countWait", adminService.countWait());
        // 상태가 탈퇴인 회원 수 출력
        model.addAttribute("countWithdrawal", adminService.countWithdrawal());

        return "admin/admin_member";
    }
    @GetMapping("/admin/member/search")
    public String adminmemberSearch(PageRequestDTO pageRequestDTO, Model model){

        log.info("pageRequestDTO:{}",pageRequestDTO);

        // 전체회원 수 출력
        model.addAttribute("countAllUsers", adminService.countAllUsers());
        // 신규가입 수 출력(현재 시간으로부터 6개월까지)
        model.addAttribute("countSixMonthUsers", adminService.countSixMonthUsers());
        // 상태가 휴면인 회원 수 출력
        model.addAttribute("countWait", adminService.countWait());
        // 상태가 탈퇴인 회원 수 출력
        model.addAttribute("countWithdrawal", adminService.countWithdrawal());

        PageResponseAdminUsersDTO pageResponseDTO = adminService.selectAllUsers(pageRequestDTO);
        model.addAttribute("pageResponseDTO", pageResponseDTO);
        model.addAttribute("pageRequestDTO", pageRequestDTO);

        return "admin/admin_member_searchList";
    }

    @GetMapping("/admin/env")
    public String env(){
        return "admin/admin_env";
    }
    @GetMapping("/admin/prod")
    public String prod(Model model, PFundPageRequestDTO pageRequestDTO){

        log.info("pageRequestDTO={}", pageRequestDTO);
        PageResponseAdminProductDTO pageResponseDTO = adminService.selectAllProduct(pageRequestDTO);

        model.addAttribute("pbIRP", adminService.avgByItem("IRP"));
        model.addAttribute("pbDC", adminService.avgByItem("DC"));
        model.addAttribute("pbDB", adminService.avgByItem("DB"));

        model.addAttribute("Danger1Fund", adminService.countByDanger(1));
        model.addAttribute("Danger2Fund", adminService.countByDanger(2));
        model.addAttribute("Danger3Fund", adminService.countByDanger(3));
        model.addAttribute("Danger4Fund", adminService.countByDanger(4));
        model.addAttribute("Danger5Fund", adminService.countByDanger(5));
        model.addAttribute("Danger6Fund", adminService.countByDanger(6));

        model.addAttribute("pageResponseDTO", pageResponseDTO);
        return "admin/admin_prod";
    }

    @GetMapping("/admin/prod/register")
    public String prodregisterGet(){
        return "admin/admin_prodRegister";
    }

    @PostMapping("/admin/prod/register")
    public String prodregisterPost(ProductDTO productDTO,
                                   @RequestParam("pcprdstart") String pcrdstart,
                                   @RequestParam("pcprdend") String pcprdend) {

        String pcprd = pcrdstart + "~" + pcprdend + "개월";

        productDTO.setPcprd(pcprd);

//        pid, ptype, pname, pbirate, phirate, pcprd, pelgbl, 컬럼
//                prmthd, pprfcrt, pirinfo, pcond, pjnfee, pwtpi, pterms, pdirate, psubtitle, pinfo 컬럼
        adminService.insertDeposit(productDTO.getPid(),
                productDTO.getPtype(),
                productDTO.getPname(),
                productDTO.getPbirate(),
                productDTO.getPhirate(),
                productDTO.getPcprd(),
                productDTO.getPelgbl(),
                productDTO.getPrmthd(),
                productDTO.getPprfcrt(),
                productDTO.getPirinfo(),
                productDTO.getPcond(),
                productDTO.getPjnfee(),
                productDTO.getPwtpi(),
                productDTO.getPterms(),
                productDTO.getPdirate(),
                productDTO.getPsubtitle(),
                productDTO.getPinfo()
                );
        return "redirect:/admin/prod";
    }

    @GetMapping("/admin/prod/modify")
    public String prodmodify(Model model, @RequestParam("pid") String pid){

        model.addAttribute("dto", adminService.selectByProduct(pid));

        return "admin/admin_prodModify";
    }

    @PostMapping("/admin/prod/modify")
    public String prodmodifyComplete( @Param("pid") String pid,
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

        adminService.updateProduct(pid,ptype,pname,pbirate,phirate,pcprd,pelgbl,prmthd,pprfcrt,pirinfo,pcond,pjnfee,pwtpi,pterms,pdirate,psubtitle,pinfo);

        return "redirect:/admin/prod";
    }

    @GetMapping("/admin/prod/delete")
    public String proddelete(@RequestParam("pid") String pid, RedirectAttributes ra){
        log.info("pid={}", pid);

        try {
            adminService.deleteByProduct(pid);
            ra.addFlashAttribute("toastSuccess", "상품이 삭제되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("toastError", "해당 상품에 가입한 회원이 있어 삭제할 수 없습니다.");
        }


        return "redirect:/admin/prod";
    }


    @GetMapping("/admin/fund/register")
    public String fundregisterGet(){
        return "admin/admin_fundRegister";
    }

    @PostMapping("/admin/fund/register")
    public String fundregisterPost(FundDTO fundDTO) {

        adminService.insertFund(
                fundDTO.getFid(),
                fundDTO.getFname(),
                fundDTO.getFamc(),
                fundDTO.getFrlvl(),
                fundDTO.getFtype(),
                fundDTO.getFrefpr(),
                fundDTO.getFsetdt(),
                fundDTO.getFtc(),
                fundDTO.getFm1pr(),
                fundDTO.getFm3pr(),
                fundDTO.getFm6pr(),
                fundDTO.getFm12pr(),
                fundDTO.getFacmpr()
        );

        return "redirect:/admin/prod";
    }

    @GetMapping("/admin/fund/modify")
    public String fundmodify(Model model, @RequestParam("fid") String fid){

        model.addAttribute("dto", adminService.selectByFund(fid));

        return "admin/admin_fundModify";
    }

    @PostMapping("/admin/fund/modify")
    public String fundmodifycomplete(@RequestParam("fid") String fid,
                                     @RequestParam("fname") String fname,
                                     @RequestParam("famc") String famc,
                                     @RequestParam("frlvl") String frlvl,
                                     @RequestParam("ftype") String ftype,
                                     @RequestParam("frefpr") String frefpr,
                                     @RequestParam("fsetdt") String fsetdt,
                                     @RequestParam("ftc") String ftc,
                                     @RequestParam("fm1pr") String fm1pr,
                                     @RequestParam("fm3pr") String fm3pr,
                                     @RequestParam("fm6pr") String fm6pr,
                                     @RequestParam("fm12pr") String fm12pr,
                                     @RequestParam("facmpr") String facmpr
                                     ){

        adminService.updateFund(fid, fname, famc, frlvl, ftype, frefpr, fsetdt, ftc, fm1pr, fm3pr, fm6pr, fm12pr, facmpr);

        return "redirect:/admin/prod";
    }


    @GetMapping("/admin/fund/delete")
    public String funddelete(@RequestParam("fid") String fid, RedirectAttributes ra){
        log.info("fid={}", fid);

        try {
            adminService.deleteByFund(fid);
            ra.addFlashAttribute("toastSuccess", "상품이 삭제되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("toastError", "해당 상품에 가입한 회원이 있어 삭제할 수 없습니다.");
        }


        return "redirect:/admin/prod";
    }

    /* ///////////////////////////
     * 고객센터 관리 (전세현)
     * /////////////////////////// */

    //목록 출력하기
    @GetMapping("/admin/cs")
    public String csList(
            @RequestParam(defaultValue = "cs") String group,   // cs / form / data
            @RequestParam(defaultValue = "faq") String type,   // faq / doc / qna / ....
            @RequestParam(required = false) String keyword,    // 🔍 검색어
            @RequestParam(required = false, defaultValue = "all") String condition, // 상태
            Model model
    ) {
        log.info("admin cs list group={}, type={}", group, type);

        boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());

        // 기본 값: 빈 리스트
        List<DocumentDTO> docList = List.of();
        List<BranchDTO>   branchList = List.of();

        // =======================
        // 1) 영업점(찾기)인 경우
        // =======================
        if ("cs".equals(group) && "branch".equals(type)) {
            if (hasKeyword) {
                // 주소/지점명 등에서 검색 (이미 BranchService에 있음)
                branchList = branchService.searchBranches(keyword);
            } else {
                branchList = branchService.getAllBranches();
            }

            // =======================
            // 2) 나머지는 DOCUMENT
            // =======================
        } else {
            String doctype = documentService.resolveDoctype(group, type);
            if (doctype == null) {
                throw new IllegalArgumentException("지원하지 않는 group/type: " + group + "/" + type);
            }

            // 일단 해당 DOCTYPE 전체 로드 (기존 방식)
            List<DocumentDTO> all = documentService.getAdminDocuments(doctype);

            // 🔍 2-1) 제목/내용 키워드 필터
            if (hasKeyword) {
                String kw = keyword.toLowerCase();
                all = all.stream()
                        .filter(dto -> {
                            String title = dto.getDoctitle() != null ? dto.getDoctitle().toLowerCase() : "";
                            String content = dto.getDoccontent() != null ? dto.getDoccontent().toLowerCase() : "";
                            return title.contains(kw) || content.contains(kw);
                        })
                        .toList();
            }

            // 🔍 2-2) 상태(condition) 필터
            //  - complete(답변): 답변 있음
            //  - wait(대기) / accept(접수): 답변 없음 으로 일단 처리
            if (condition != null && !"all".equals(condition)) {
                all = all.stream()
                        .filter(dto -> {
                            String answer = dto.getDocanswer();
                            boolean hasAnswer = (answer != null && !answer.isBlank());

                            switch (condition) {
                                case "complete": // 답변
                                    return hasAnswer;
                                case "wait":     // 대기
                                case "accept":   // 접수 (별도 컬럼 없으니 일단 '답변 없음'으로)
                                    return !hasAnswer;
                                default:
                                    return true;
                            }
                        })
                        .toList();
            }

            docList = all;
        }

        // 뷰로 전달
        model.addAttribute("group", group);
        model.addAttribute("type", type);
        model.addAttribute("keyword", keyword);     // 🔁 검색어 유지용
        model.addAttribute("condition", condition); // 🔁 상태 유지용
        model.addAttribute("docList", docList);
        model.addAttribute("branchList", branchList);

        return "admin/admin_cs";
    }

    //등록하기
    // 등록 폼
    @GetMapping("/admin/cs/register")
    public String csRegisterForm(
            @RequestParam String group,
            @RequestParam String type,
            Model model) {

        model.addAttribute("group", group);
        model.addAttribute("type", type);

        // 🔴 영업점 찾기인 경우: BRANCH용 폼
        if ("BRANCH".equalsIgnoreCase(type)) {
            model.addAttribute("branch", new BranchDTO());
            return "admin/admin_branchRegister"; // ← 영업점 등록 템플릿
        }

        // 🔵 그 외: DOCUMENT용 폼
        DocumentDTO dto = new DocumentDTO();
        dto.setDocgroup(group); // 기본값 세팅(선택)
        model.addAttribute("document", dto);

        return "admin/admin_csregister"; // 지금 만들어둔 게시글 등록 폼
    }

    @PostMapping("/admin/cs/register")
    public String csRegister(
            DocumentDTO documentDTO,
            BranchDTO branchDTO,          // 🔴 영업점용 DTO 같이 받기
            @RequestParam String group,
            @RequestParam String type,
            RedirectAttributes ra
    ) {
        // 1️⃣ 영업점(찾기) → BRANCH 테이블 등록 후 바로 리턴
        if ("branch".equalsIgnoreCase(type)) {

            // 필요하다면 검증/기본값 세팅 등 추가
            // ex) if (branchDTO.getBrname() == null || branchDTO.getBrname().isBlank()) { ... }

            branchService.insertBranch(branchDTO);   // 🔥 BRANCH INSERT

            ra.addFlashAttribute("toastSuccess", "영업점이 등록되었습니다.");
            return "redirect:/admin/cs?group=" + group + "&type=" + type;
        }

        // 2️⃣ 나머지 타입 → DOCUMENT 테이블에 등록 (기존 로직)
        documentDTO.setDocgroup(group);

        // ★ 여기부터는 branch 가 아닌 경우에만 타도록!
        String doctype = documentService.resolveDoctype(group, type);
        if (doctype == null) {
            throw new IllegalArgumentException("지원하지 않는 group/type: " + group + "/" + type);
        }
        documentDTO.setDoctype(doctype);

        if (documentDTO.getMid() == null) {
            documentDTO.setMid("admin");
        }

        // null 방지
        if (documentDTO.getDocanswer() == null) {
            documentDTO.setDocanswer("");
        }
        if (documentDTO.getDocfile() == null) {
            documentDTO.setDocfile("");
        }

        documentService.insertAdminDocument(documentDTO);

        ra.addFlashAttribute("toastSuccess", "게시물이 등록되었습니다.");
        return "redirect:/admin/cs?group=" + group + "&type=" + type;
    }




    //수정하기
    @GetMapping("/admin/cs/modify")
    public String csModifyForm(
            @RequestParam int docid,
            @RequestParam String group,
            @RequestParam String type,
            Model model
    ){
        DocumentDTO dto = documentService.getDocumentById(docid);

        model.addAttribute("group", group);
        model.addAttribute("type", type);
        model.addAttribute("document", dto);

        return "admin/admin_csmodify";
    }

    @PostMapping("/admin/cs/modify")
    public String csModify(
            DocumentDTO documentDTO,
            @RequestParam String group,
            @RequestParam String type,
            RedirectAttributes ra
    ){
        // docgroup / doctype 건드리지 않고,
        // 제목/내용/답변/파일만 수정
        documentService.updateAdminDocument(documentDTO);

        ra.addFlashAttribute("toastSuccess", "게시물이 수정되었습니다.");
        return "redirect:/admin/cs?group=" + group + "&type=" + type;
    }

    // =========================
    //  영업점(Branch) 수정
    // =========================
    @GetMapping("/admin/cs/branch/modify")
    public String branchModifyForm(
            @RequestParam int brid,
            @RequestParam String group,
            @RequestParam String type,
            Model model
    ) {
        BranchDTO branch = branchService.getBranchById(brid);

        model.addAttribute("group", group);
        model.addAttribute("type", type);
        model.addAttribute("branch", branch);

        return "admin/admin_branchModify";
    }

    @PostMapping("/admin/cs/branch/modify")
    public String branchModify(
            BranchDTO branchDTO,
            @RequestParam String group,
            @RequestParam String type,
            RedirectAttributes ra
    ) {
        branchService.updateBranch(branchDTO);
        ra.addFlashAttribute("toastSuccess", "영업점 정보가 수정되었습니다.");

        return "redirect:/admin/cs?group=" + group + "&type=" + type;
    }


    //삭제하기
    @PostMapping("/admin/cs/delete")
    public String csDelete(
            @RequestParam int docid,
            @RequestParam String group,
            @RequestParam String type,
            RedirectAttributes ra
    ){
        if("cs".equals(group) && "branch".equals(type)) {
            branchService.deleteBranch(docid);
            ra.addFlashAttribute("toastSuccess","영업점 정보가 삭제되었습니다.");
        }else{
            documentService.deleteAdminDocument(docid);
            ra.addFlashAttribute("toastSuccess","게시물이 삭제되었습니다.");
        }

        return "redirect:/admin/cs?group=" + group + "&type=" + type;
    }

    // 고객센터 리스트 JSON 디버그용
    @GetMapping("/admin/cs/debug")
    @ResponseBody
    public PageResponseAdminDocumentDTO csListDebug(
            @RequestParam(defaultValue = "cs") String group,   // cs / form / data
            @RequestParam(defaultValue = "faq") String type,   // faq / qna / db / notice ...
            PageRequestDTO pageRequestDTO
    ) {
        log.info("admin cs DEBUG group={}, type={}, page={}", group, type, pageRequestDTO);

        return documentService.getAdminDocumentPage(group, type, pageRequestDTO);
    }

    // ===== Q&A 답변 작성 화면 열기 =====
    @GetMapping("/admin/cs/qna/answer")
    public String showQnaAnswerForm(
            @RequestParam("docid") int docid,
            @RequestParam("group") String group,
            @RequestParam("type") String type,
            Model model
    ) {
        DocumentDTO qna = documentService.getDocumentById(docid);
        if (qna == null) {
            return "redirect:/admin/cs?group=" + group + "&type=" + type;
        }

        model.addAttribute("qna", qna);
        model.addAttribute("group", group);
        model.addAttribute("type", type);

        // templates/admin/cs_qna_answer.html
        return "admin/cs_qna_answer";
    }


    // ===== Q&A 답변 등록 처리 (POST) =====
    @PostMapping("/admin/cs/qna/answer")
    public String submitQnaAnswer(
            @RequestParam("docid") int docid,
            @RequestParam("group") String group,
            @RequestParam("type") String type,
            @RequestParam("answerContent") String answerContent,
            RedirectAttributes rttr
    ) {
        DocumentDTO dto = documentService.getDocumentById(docid);
        if (dto == null) {
            rttr.addFlashAttribute("error", "존재하지 않는 문의입니다.");
            return "redirect:/admin/cs?group=" + group + "&type=" + type;
        }

        // ⭐ DOCANSWER 컬럼에 답변 내용 저장
        dto.setDocanswer(answerContent);

        // 기존 관리자 수정 로직 재사용 (UPDATE)
        documentService.updateAdminDocument(dto);

        rttr.addFlashAttribute("msg", "답변이 등록되었습니다.");
        return "redirect:/admin/cs?group=" + group + "&type=" + type;
    }

}

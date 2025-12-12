package kr.co.bnkfirst.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.entity.Users;
import kr.co.bnkfirst.jwt.JwtProvider;
import kr.co.bnkfirst.security.MyUserDetails;
import kr.co.bnkfirst.service.UsersService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/member")
public class UsersController {
    private final JwtProvider jwtProvider;
    private final UsersService usersService;

    /*
        날짜 : 2025/11/21
        이름 : 이준우
        내용 : 로그인 세션 + jwt 하이브리드 방식 변경
     */

    @PostMapping("/login")
    public String login(@RequestParam String mid,
                        @RequestParam String mpw,
                        HttpSession session, RedirectAttributes ra) {

        log.info("로그인 시도 ID: {}", mid);

        UsersDTO dto = usersService.login(mid, mpw);

        if (dto == null) {

            ra.addFlashAttribute("loginErrorMsg", "회원 정보가 일치하지 않습니다.");
            return "redirect:/member/main";
        }

        // 최근 접속일자
        usersService.updateLastAccess(dto.getMid());

        // JWT 생성
        Users user = dto.toEntity();
        String role = dto.getRole();
        String token = jwtProvider.createToken(user, role);
        log.info("token: {}", token);

        // 세션 저장
        session.setAttribute("jwtToken", token);
        session.setAttribute("loginUser", dto);

        long now = System.currentTimeMillis();
        session.setAttribute("sessionStart", now);
        session.setMaxInactiveInterval(1200);

        log.info("로그인 성공 - ID: {}, JWT 발급됨, 세션 시작시간: {}", mid, now);

        ra.addFlashAttribute("loginSuccessMsg", dto.getMname() + "님 반갑습니다. 환영합니다");

        return "redirect:/main/main";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {

        Object userObj = session.getAttribute("loginUser");

        if (userObj != null) {
            UsersDTO user = (UsersDTO) userObj;
            log.info("사용자 로그아웃: {}", user.getMid());
        } else {
            log.info("로그아웃 요청: 로그인된 사용자 없음");
        }

        session.invalidate();
        return "redirect:/member/main";
    }

    @GetMapping("/main")
    public String memberMain(Model model, HttpSession session) {

        UsersDTO loginUser = (UsersDTO) session.getAttribute("loginUser");

        if (loginUser != null) {
            return "redirect:/main/main";
        }

        model.addAttribute("userDTO", new UsersDTO());

        return "member/member_main";
    }

    @GetMapping("/terms")
    public String memberTerms() {
        return "member/member_terms";
    }

    @PostMapping("/auth/save")
    public String authSave(@ModelAttribute UsersDTO dto, HttpSession session) {

        // 세션 저장
        session.setAttribute("authData", dto);

        return "redirect:/member/info";
    }

    @GetMapping("/auth")
    public String memberAuth(HttpSession session, HttpServletRequest request) {
        String referer = request.getHeader("Referer");

        if (referer == null || !referer.contains("/member/terms")) {

            // terms 넘어온 게 아니면 차단
            return "redirect:/member/terms";
        }
        return "member/member_auth";
    }

    @GetMapping("/info")
    public String memberInfo(HttpSession session, Model model) {
        // 인증 단계 건너뛰기 방지
        UsersDTO authData = (UsersDTO) session.getAttribute("authData");
        if (authData == null) {
            return "redirect:/member/auth";
        }

        model.addAttribute("auth", authData);
        return "member/member_info";
    }

    // 회원가입 데이터 저장
    @PostMapping("/insert")
    public String insert(@ModelAttribute UsersDTO usersDTO, HttpSession session) {
        boolean result = usersService.register(usersDTO);

        if (result) {
            UsersDTO savedUser = usersService.findByMid(usersDTO.getMid());
            session.setAttribute("newUser", savedUser);

            String accountNo = usersService.openDefaultAccount(savedUser.getMid());
            session.setAttribute("newAccountNo", accountNo);

            session.removeAttribute("authData");

            return "redirect:/member/active";
        } else {
            return "redirect:/member/info";
        }
    }

    @GetMapping("/id-check")
    @ResponseBody
    public boolean idCheck(@RequestParam String mid) {
        return usersService.existsByMid(mid);
    }

    @GetMapping("/active")
    public String memberActive(HttpSession session, Model model) {

        UsersDTO newUser = (UsersDTO) session.getAttribute("newUser");
        String newAccountNo = (String) session.getAttribute("newAccountNo");

        if (newUser == null || newAccountNo == null) {
            return "redirect:/member/info";
        }
        String xml =
                "<extra>" +
                        "   <grade>Family</grade>" +
                        "   <joinDate>SYSDATE</joinDate>" +
                        "</extra>";

        model.addAttribute("member", newUser);
        model.addAttribute("xml", xml);

        // 계좌 및 비밀번호 추가 (2025.11.27 이준우)
        model.addAttribute("accountNo", newAccountNo);
        model.addAttribute("initAccountPw", "1234");

        // 회원가입 완료 후 세션 초기화
        session.removeAttribute("newUser");
        session.removeAttribute("newAccountNo");

        return "member/member_active";
    }

    // findId
    @PostMapping("/findid/phone")
    @ResponseBody
    public Map<String, Object> findIdByPhone(@RequestBody Map<String, String> request) {

        String name = request.get("name");
        String phone = request.get("phone");

        String mid = usersService.findIdByPhone(name, phone);

        if (mid == null) {
            return Map.of("ok", false,"message", "해당 휴대폰 번호로 가입된 아이디가 없습니다.");
        }

        return Map.of("ok", true,"mid", mid);
    }

    @PostMapping("/findid/email")
    @ResponseBody
    public Map<String, Object> findIdByEmail(@RequestBody Map<String, String> request) {

        String name = request.get("name");
        String email = request.get("email");

        String mid = usersService.findIdByEmail(name, email);

        if (mid == null) {
            return Map.of("ok", false, "message", "해당 정보와 일치하는 아이디가 없습니다.");
        }

        return Map.of("ok", true, "mid", mid);
    }

    @GetMapping("/findid")
    public String memberFindid() {
        return "member/member_findid";
    }

    // findpw
    @PostMapping("/findpw/phone")
    @ResponseBody
    public Map<String, Object> findPwByPhone(@RequestBody Map<String, String> request) {

        String mid = request.get("mid");
        String phone = request.get("phone");

        String tempPw = usersService.resetPasswordByPhone(mid, phone);

        if(tempPw == null) {
            return Map.of("ok", false, "message", "일치하는 회원이 없습니다");
        }
        return Map.of("ok", true,"tempPw", tempPw);
    }

    @PostMapping("/findpw/email")
    @ResponseBody
    public Map<String, Object> findPwByEmail(@RequestBody Map<String, String> request) {

        String mid = request.get("mid");
        String email = request.get("email");

        String tempPw = usersService.resetPasswordByEmail(mid, email);

        if(tempPw == null) {
            return Map.of("ok", false, "message", "일치하는 회원이 없습니다");
        }
        return Map.of("ok", true,"tempPw", tempPw);
    }

    @GetMapping("/findpw")
    public String memberFindpw() {
        return "member/member_findpw";
    }

    // 현재 세션 남은 시간 조회
    @GetMapping("/session/remaining")
    @ResponseBody
    public Map<String, Object> getRemaining(HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        Object loginUser = session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("remainSeconds", 0);
            return result;
        }
        Long startTime = (Long) session.getAttribute("sessionStart");
        if (startTime == null) {
            // 혹시 null이면 다시 저장 (예외 처리용)
            startTime = System.currentTimeMillis();
            session.setAttribute("sessionStart", startTime);
        }
        long now = System.currentTimeMillis();
        long passed = (now - startTime) / 1000;
        long remain = 1200 - passed;
        if (remain < 0) remain = 0;

        result.put("remainSeconds", remain);
        return result;
    }

    // 세션 연장 (다시 20분으로 리셋)
    @PostMapping("/session/extend")
    @ResponseBody
    public Map<String, Object> extend(HttpSession session) {

        Object loginUser = session.getAttribute("loginUser");
        if (loginUser == null) {
            return Map.of("remainSeconds", 0);
        }
        session.setAttribute("sessionStart", System.currentTimeMillis());
        session.setMaxInactiveInterval(1200);

        return getRemaining(session);
    }

    // 금융인증서 추가(11월19일)
    // 공동인증서 모의 인증으로 변경 : 파일 + 비밀번호 확인용(11월24일)
    @PostMapping("/api/joint-cert/verify")
    @ResponseBody
    public Map<String, Object> verifyJointCert(
            @RequestParam("certFile")MultipartFile certFile,
            @RequestParam("certPw") String certPw,
            HttpSession session
    ){
        // 파일 선택 조건
        if (certFile == null || certFile.isEmpty()) {

            return Map.of("ok", false, "message", "공동인증서 파일을 선택해 주세요.");
        }
        String originalName = certFile.getOriginalFilename();
        if (originalName == null || originalName.isBlank()) {

            return Map.of("ok", false, "message", "유효한 파일명을 찾을 수 없습니다.");
        }

        String lower = originalName.toLowerCase();
        boolean imageOk = lower.endsWith(".jpg")
                || lower.endsWith(".png")
                || lower.endsWith(".jpeg");
        if (!imageOk) {

            return Map.of("ok", false, "message", "jpg, jpeg, png 형식의 파일만 업로드할 수 있습니다.");
        }

        // 비밀번호 조건
        if (certPw == null || !certPw.trim().equals("123456")) {

            return Map.of("ok", false, "message", "인증서 비밀번호가 올바르지 않습니다.");
        }

        // 모의 인증
        session.setAttribute("JOINT_CERT_AUTH", true);

        return Map.of("ok", true, "fileName", originalName);
    }

    // 회원 탈퇴 추가 (이준우 2025.11.28)
    @PostMapping("/withdraw")
    public String withdraw(@AuthenticationPrincipal MyUserDetails principal,
                           @RequestParam("mpw")   String mpw,
                           @RequestParam("mphone") String mphone,
                           HttpSession session,
                           RedirectAttributes rttr) {

        String mid = principal.getUsername();

        try {
            boolean ok = usersService.withdrawUser(mid, mpw, mphone);

            if (!ok) {
                rttr.addFlashAttribute("msg", "탈퇴 조건이 맞지 않습니다. (비밀번호/휴대폰 번호 확인)");
                return "redirect:/member/mypage";
            }

            session.invalidate();

            rttr.addFlashAttribute("msg", "회원이 탈퇴되었습니다. 이용해 주셔서 감사합니다.");
            return "redirect:/member/main";

        } catch (Exception e) {
            log.error("회원 탈퇴 중 오류", e);
            rttr.addFlashAttribute("msg", "탈퇴 처리 중 오류가 발생했습니다.");
            return "redirect:/member/mypage";
        }
    }
}
package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.service.QrAuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Controller
@RequestMapping("/auth/qr")
@RequiredArgsConstructor
public class QrAuthController {

    private final QrAuthService qrAuthService;

    // PC용 QR 띄우는 페이지
    @GetMapping("/start")
    public String startQrAuth(Model model) {
        String token = UUID.randomUUID().toString();
        qrAuthService.createSession(token);      // PENDING 상태로 저장
        model.addAttribute("qrToken", token);    // ✅ 이 이름 그대로!
        return "account/IRPaccount_page4";       // ✅ QR 페이지 템플릿
    }

    // ✅ 1) 모바일에서 QR 열었을 때 나오는 페이지
    @GetMapping("/mobile")
    public String mobilePage(@RequestParam String token, Model model) {
        String status = qrAuthService.getStatus(token);

        // 토큰이 없거나 만료된 경우
        if ("NOT_FOUND".equals(status) || "EXPIRED".equals(status)) {
            model.addAttribute("invalid", true);
            return "account/IRPaccount_qr_mobile";
        }

        model.addAttribute("invalid", false);
        model.addAttribute("token", token);
        return "account/IRPaccount_qr_mobile";   // 아래에서 만들 HTML
    }

    // ✅ 2) 모바일에서 정보 입력 후 "인증 완료" 눌렀을 때
    @PostMapping("/verify")
    public String verify(
            @RequestParam String token,
            @RequestParam String name,
            @RequestParam String birth,
            @RequestParam String phone,
            Model model
    ) {
        try {
            qrAuthService.verify(token, name, birth, phone);
            model.addAttribute("success", true);
        } catch (IllegalArgumentException e) {
            model.addAttribute("success", false);
            model.addAttribute("message", e.getMessage());
        }
        return "account/IRPaccount_qr_result";   // 완료 안내 모바일 페이지
    }

    // ✅ 3) PC에서 2초마다 상태 확인하는 API (JSON)
    @GetMapping("/status")
    @ResponseBody
    public Map<String, String> getStatus(@RequestParam String token) {
        String status = qrAuthService.getStatus(token); // PENDING / VERIFIED / EXPIRED / NOT_FOUND

        Map<String, String> res = new HashMap<>();
        res.put("status", status);
        return res;
    }
}



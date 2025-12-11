package kr.co.bnkfirst.controller;

import jakarta.validation.Valid;
import kr.co.bnkfirst.dto.corporate.employee.*;
import kr.co.bnkfirst.service.EmployeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.Map;
import java.util.List;


@Controller
@RequiredArgsConstructor
@RequestMapping("/corporate/employee")
public class EmployeeController {

    private final EmployeeService employeeService;

    /** =====================================
     *  직원 목록 (검색 + 페이지네이션)
     *  ===================================== */
    @GetMapping("/list")
    public String list(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false, defaultValue = "ALL") String planType,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size,
            Model model
    ) {

        // OFFSET 계산
        int offset = (page - 1) * size;

        // 직원 목록 + 검색 + 페이지네이션
        List<EmployeeListDto> employees =
                employeeService.getEmployeePage(keyword, planType, offset, size);

        // 총 데이터 수
        int totalCount =
                employeeService.getEmployeeTotalCount(keyword, planType);

        // 총 페이지 수
        int totalPages = (int) Math.ceil((double) totalCount / size);

        // 모델 전달
        model.addAttribute("employees", employees);

        model.addAttribute("keyword", keyword);
        model.addAttribute("planType", planType);

        model.addAttribute("page", page);
        model.addAttribute("totalPages", totalPages);

        return "corporate/employee/list";
    }



    /** =====================================
     *  직원 상세
     *  ===================================== */
    @GetMapping("/detail/{empId}")
    public String detail(@PathVariable Long empId, Model model) {

        model.addAttribute("employee", employeeService.getEmployeeDetail(empId));
        model.addAttribute("contributions", employeeService.getEmployeeContributions(empId));
        model.addAttribute("currentBalance", employeeService.getEmployeeCurrentBalance(empId));

        // 왼쪽 리스트
        model.addAttribute("employees", employeeService.getEmployeeList());

        return "corporate/employee/detail";
    }


    /** =====================================
     *  직원 수정 화면
     *  ===================================== */
    @GetMapping("/edit/{empId}")
    public String edit(@PathVariable Long empId, Model model) {

        model.addAttribute("employee", employeeService.getEmployeeDetail(empId));
        model.addAttribute("employeeUpdateDto", new EmployeeUpdateDto());

        return "corporate/employee/edit";
    }


    /** =====================================
     *  직원 수정 실행
     *  ===================================== */
    @PostMapping("/edit/{empId}")
    public String editAction(
            @PathVariable Long empId,
            @Valid @ModelAttribute("employeeUpdateDto") EmployeeUpdateDto dto,
            BindingResult bindingResult,
            Model model
    ) {

        if (bindingResult.hasErrors()) {
            model.addAttribute("employee", employeeService.getEmployeeDetail(empId));
            return "corporate/employee/edit";
        }

        dto.setEmpId(empId);
        employeeService.updateEmployee(dto);

        return "redirect:/corporate/employee/detail/" + empId;
    }


    /** =====================================
     *  직원 삭제 확인
     *  ===================================== */
    @GetMapping("/delete/{empId}")
    public String deleteConfirm(@PathVariable Long empId, Model model) {
        model.addAttribute("employee", employeeService.getEmployeeDetail(empId));
        model.addAttribute("employeeDeleteDto", new EmployeeDeleteDto());
        return "corporate/employee/delete";   // 🔥 템플릿 제대로 반환
    }



    /** =====================================
     *  직원 삭제 실행
     *  ===================================== */
    @PostMapping("/delete/{empId}")
    public String deleteAction(
            @PathVariable Long empId,
            @ModelAttribute("employeeDeleteDto") EmployeeDeleteDto dto
    ) {
        employeeService.deleteEmployee(empId);
        return "redirect:/corporate/employee/list";
    }


    /** =====================================
     *  직원 납입 내역
     *  ===================================== */
    @GetMapping("/contribution/{empId}")
    public String contribution(@PathVariable Long empId, Model model) {

        model.addAttribute("employee", employeeService.getEmployeeDetail(empId));
        model.addAttribute("contributions", employeeService.getEmployeeContributions(empId));
        model.addAttribute("currentBalance", employeeService.getEmployeeCurrentBalance(empId));

        return "corporate/employee/contribution_list";
    }


    /** =====================================
     *  ⭐ 직원 자동완성 API (JSON)
     *  ===================================== */
    @GetMapping("/autocomplete")
    @ResponseBody
    public List<EmployeeAutoDto> autocomplete(@RequestParam String keyword) {
        return employeeService.autocomplete(keyword);
    }

    /** =====================================
     *  ⭐ 직원 상태 변경 (재직/휴직 공통)
     *  ===================================== */
    @PostMapping("/status/{empId}")
    @ResponseBody
    public ResponseEntity<?> updateStatus(
            @PathVariable Long empId,
            @RequestBody Map<String, String> body
    ) {
        String status = body.get("status");
        employeeService.updateStatus(empId, status);
        return ResponseEntity.ok().build();
    }


    /** =====================================
     *  ⭐ 직원 퇴사 처리 (퇴사일 포함)
     *  ===================================== */
    @PostMapping("/retire/{empId}")
    @ResponseBody
    public ResponseEntity<?> retireEmployee(
            @PathVariable Long empId,
            @RequestBody Map<String, String> body
    ) {
        String status = body.get("status");       // ⭐ 반드시 필요
        String retireDate = body.get("retireDate");

        employeeService.retire(empId, status, retireDate);   // ⭐ status 함께 전달
        return ResponseEntity.ok().build();
    }

    @GetMapping("/create")
    public String createForm(Model model) {
        model.addAttribute("employeeCreateDto", new EmployeeCreateDto());
        return "corporate/employee/create";   // ✔ 수정
    }

    @PostMapping("/create")
    public String create(@ModelAttribute @Valid EmployeeCreateDto dto) {
        employeeService.createEmployee(dto);
        return "redirect:/corporate/employee/list";   // ✔ 수정
    }


}

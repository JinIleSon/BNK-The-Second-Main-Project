package kr.co.bnkfirst.dto.corporate.employee;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class EmployeeCreateDto {

    @NotBlank(message = "이름은 필수입니다.")
    private String name;

    @NotBlank(message = "제도(DB/DC)는 필수입니다.")
    private String planType;

    @NotBlank(message = "계좌번호는 필수입니다.")
    private String accountNo;

    // 선택값
    private String department;   // 마케팅 / 개발 / 경영지원 / 디자인
    private String position;     // 사원 / 주임 / 대리 / 과장

    // 기본값: ACTIVE
    private String status = "ACTIVE";

    // yyyy-MM-dd 형식
    private String hireDate;
}

package kr.co.bnkfirst.dto.corporate.employee;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class EmployeeUpdateDto {

    @NotNull(message = "직원 ID는 필수입니다.")
    private Long empId;

    @NotBlank(message = "이름은 필수입니다.")
    private String name;

    @NotBlank(message = "제도(DB/DC)입니다.")
    private String planType;

    @NotBlank(message = "계좌번호는 필수입니다.")
    private String accountNo;

    @NotBlank(message = "재직 상태는 필수입니다.")
    private String status;
}

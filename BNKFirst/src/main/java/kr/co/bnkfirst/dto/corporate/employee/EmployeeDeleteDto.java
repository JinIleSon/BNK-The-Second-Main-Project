package kr.co.bnkfirst.dto.corporate.employee;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class EmployeeDeleteDto {

    @NotNull(message = "직원 ID는 필수입니다.")
    private Long empId;
}

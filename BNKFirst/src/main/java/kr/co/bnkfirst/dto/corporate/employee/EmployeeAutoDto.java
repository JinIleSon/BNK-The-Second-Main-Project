package kr.co.bnkfirst.dto.corporate.employee;

import lombok.Data;

@Data
public class EmployeeAutoDto {
    private Long empId;       // 직원 ID
    private String name;      // 직원 이름
    private String accountNo; // 계좌번호
}

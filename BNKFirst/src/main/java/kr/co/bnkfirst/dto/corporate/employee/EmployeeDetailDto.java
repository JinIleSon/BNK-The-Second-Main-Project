package kr.co.bnkfirst.dto.corporate.employee;

import lombok.Data;

@Data
public class EmployeeDetailDto {

    private Long empId;
    private String name;
    private String planType;
    private String accountNo;
    private String status;

    // DB 컬럼이 아닌 계산 필드
    private Long currentBalance = 0L;
}

package kr.co.bnkfirst.dto.corporate.employee;

import lombok.Data;

@Data
public class EmployeeListDto {
    private Long empId;
    private String name;
    private String planType;
    private String accountNo;
    private String status;
    private String position;
    private String department;
}

package kr.co.bnkfirst.domain;

import lombok.Data;

@Data
public class Employee {
    private Long empId;
    private String name;
    private String planType;
    private String accountNo;
    private String status;
}

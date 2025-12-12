package kr.co.bnkfirst.dto.corporate.employee;

import lombok.Data;

@Data
public class EmployeeContributionDto {
    private String yearMonth;
    private Long amount;
    private Long cumulative;
}

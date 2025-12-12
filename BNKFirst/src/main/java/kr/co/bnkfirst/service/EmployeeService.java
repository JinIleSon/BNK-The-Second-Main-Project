package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.corporate.employee.EmployeeCreateDto;
import kr.co.bnkfirst.dto.corporate.employee.EmployeeListDto;
import kr.co.bnkfirst.dto.corporate.employee.EmployeeDetailDto;
import kr.co.bnkfirst.dto.corporate.employee.EmployeeContributionDto;
import kr.co.bnkfirst.dto.corporate.employee.EmployeeUpdateDto;
import kr.co.bnkfirst.dto.corporate.employee.EmployeeAutoDto;

import java.util.List;

public interface EmployeeService {

    // ⭐ Create
    void createEmployee(EmployeeCreateDto dto);

    // ⭐ Read
    List<EmployeeListDto> getEmployeeList();
    EmployeeDetailDto getEmployeeDetail(Long empId);
    List<EmployeeContributionDto> getEmployeeContributions(Long empId);
    int getTotalEmployees();
    List<EmployeeListDto> search(String keyword, String planType);
    Long getEmployeeCurrentBalance(Long empId);

    // ⭐ Update
    void updateEmployee(EmployeeUpdateDto dto);
    void updateStatus(Long empId, String status);    // 재직/휴직
    void retire(Long empId, String status, String retireDate); // 퇴사

    // ⭐ Delete
    void deleteEmployee(Long empId);

    // 자동완성
    List<EmployeeAutoDto> autocomplete(String keyword);

    // 페이지네이션
    List<EmployeeListDto> getEmployeePage(String keyword, String planType, int offset, int size);
    int getEmployeeTotalCount(String keyword, String planType);
}

package kr.co.bnkfirst.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import kr.co.bnkfirst.mapper.EmployeeMapper;
import kr.co.bnkfirst.dto.corporate.employee.*;

import java.util.List;


@Service
@RequiredArgsConstructor
public class EmployeeServiceImpl implements EmployeeService {

    private final EmployeeMapper employeeMapper;

    @Override
    public void createEmployee(EmployeeCreateDto dto) {
        employeeMapper.insertEmployee(dto);
    }

    @Override
    public List<EmployeeListDto> getEmployeeList() {
        return employeeMapper.findAllEmployees();
    }

    @Override
    public EmployeeDetailDto getEmployeeDetail(Long empId) {
        return employeeMapper.findEmployeeById(empId);
    }

    @Override
    public void updateEmployee(EmployeeUpdateDto dto) {
        employeeMapper.updateEmployee(dto);
    }

    @Override
    public void deleteEmployee(Long empId) {
        employeeMapper.deleteEmployee(empId);
    }

    @Override
    public void updateStatus(Long empId, String status) {
        employeeMapper.updateStatus(empId, status);
    }

    @Override
    public void retire(Long empId, String status, String retireDate) {
        employeeMapper.updateRetire(empId, status, retireDate);
    }

    @Override
    public List<EmployeeAutoDto> autocomplete(String keyword) {
        return employeeMapper.autocomplete(keyword);
    }

    @Override
    public List<EmployeeListDto> getEmployeePage(String keyword, String planType, int offset, int size) {
        return employeeMapper.selectEmployeePage(keyword, planType, offset, size);
    }

    @Override
    public int getEmployeeTotalCount(String keyword, String planType) {
        return employeeMapper.countEmployeeList(keyword, planType);
    }

    @Override
    public Long getEmployeeCurrentBalance(Long empId) {
        return employeeMapper.getCurrentBalance(empId);
    }

    @Override
    public List<EmployeeContributionDto> getEmployeeContributions(Long empId) {
        return employeeMapper.findContributionsByEmpId(empId);
    }

    @Override
    public List<EmployeeListDto> search(String keyword, String planType) {
        return employeeMapper.search(keyword, planType);
    }

    @Override
    public int getTotalEmployees() {
        return employeeMapper.getTotalEmployees();
    }
}

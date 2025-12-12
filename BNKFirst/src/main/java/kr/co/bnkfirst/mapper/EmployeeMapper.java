package kr.co.bnkfirst.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

import kr.co.bnkfirst.dto.corporate.employee.*;

@Mapper
public interface EmployeeMapper {

    // ⭐ Create
    void insertEmployee(EmployeeCreateDto dto);

    // ⭐ Read
    List<EmployeeListDto> findAllEmployees();
    EmployeeDetailDto findEmployeeById(@Param("empId") Long empId);
    List<EmployeeContributionDto> findContributionsByEmpId(@Param("empId") Long empId);
    int getTotalEmployees();
    List<EmployeeListDto> search(@Param("keyword") String keyword,
                                 @Param("planType") String planType);

    Long getCurrentBalance(@Param("empId") Long empId);

    // ⭐ Update
    void updateEmployee(EmployeeUpdateDto dto);
    void updateStatus(@Param("empId") Long empId,
                      @Param("status") String status);
    void updateRetire(@Param("empId") Long empId,
                      @Param("status") String status,
                      @Param("retireDate") String retireDate);

    // ⭐ Delete
    void deleteEmployee(@Param("empId") Long empId);

    // ⭐ 자동완성
    List<EmployeeAutoDto> autocomplete(@Param("keyword") String keyword);

    // ⭐ 페이지네이션
    List<EmployeeListDto> selectEmployeePage(
            @Param("keyword") String keyword,
            @Param("planType") String planType,
            @Param("offset") int offset,
            @Param("size") int size
    );

    int countEmployeeList(
            @Param("keyword") String keyword,
            @Param("planType") String planType
    );
}

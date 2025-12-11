package kr.co.bnkfirst.service;

import kr.co.bnkfirst.domain.Contribution;
import java.util.List;

public interface ContributionService {

    // 직원별 납입 내역 조회 (ServiceImpl과 일치)
    List<Contribution> findByEmpId(Long empId);

    // 직원 현재 적립금 (ServiceImpl과 일치)
    Long findCurrentBalance(Long empId);

    // 전체 적립금 합계
    Long getTotalAccumulatedAmount();

    // 이번 달 납입 예정
    Long getExpectedContributionForMonth();
}

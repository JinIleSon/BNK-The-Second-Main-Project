package kr.co.bnkfirst.service;

import kr.co.bnkfirst.domain.Contribution;
import kr.co.bnkfirst.mapper.ContributionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ContributionServiceImpl implements ContributionService {

    private final ContributionMapper contributionMapper;

    @Override
    public Long getTotalAccumulatedAmount() {
        return contributionMapper.getTotalAccumulatedAmount();
    }

    @Override
    public Long getExpectedContributionForMonth() {
        return contributionMapper.getExpectedContributionForMonth();
    }

    @Override
    public List<Contribution> findByEmpId(Long empId) {
        return contributionMapper.findByEmpId(empId);
    }

    @Override
    public Long findCurrentBalance(Long empId) {
        return contributionMapper.findCurrentBalance(empId);
    }
}

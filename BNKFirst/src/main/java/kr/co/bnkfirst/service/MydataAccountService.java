package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.MydataAccountDTO;
import kr.co.bnkfirst.mapper.MydataAccountMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MydataAccountService {

    private final MydataAccountMapper mydataAccountMapper;

    //타행계좌 전체 조회
    public List<MydataAccountDTO> getMydataAccountsForUser(String mid) {
        return mydataAccountMapper.findByUserId(mid);
    }

    //PK 기준 단일 계좌 조회
    public MydataAccountDTO findByAccid(Long myaccid) {
        return mydataAccountMapper.findByAccid(myaccid);
    }
}

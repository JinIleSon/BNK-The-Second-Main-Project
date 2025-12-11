package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.product.SlfcertDTO;
import kr.co.bnkfirst.entity.product.Slfcert;
import kr.co.bnkfirst.repository.product.SlfcertRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class SlfcertService {
    private final SlfcertRepository slfcertRepository;

    public SlfcertDTO saveSlfcert(SlfcertDTO slfcertDTO){
        Slfcert entity = slfcertDTO.toEntity();
        log.info("slfcert entity : {}", entity);
        Slfcert savedSlfcert = slfcertRepository.save(entity);
        if (savedSlfcert.getId() == null){
            throw new IllegalArgumentException("SLFCERT ID가 생성되지 않았습니다.");
        }
        log.info(savedSlfcert.toString());
        return savedSlfcert.toDTO();
    }

    public boolean countSlfcertByMid(String mid){
        log.info("count slfcert by mid : {}", mid);
        long count = slfcertRepository.countByCusidAndSts(mid,"VALID");
        log.info("slfcert count : {}", count);
        return count > 0;
    }
}

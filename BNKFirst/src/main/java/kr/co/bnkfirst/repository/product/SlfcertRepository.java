package kr.co.bnkfirst.repository.product;

import kr.co.bnkfirst.entity.product.Slfcert;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SlfcertRepository extends JpaRepository<Slfcert, Integer> {
    long countByCusidAndSts(String cusid, String sts);
}

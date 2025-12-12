package kr.co.bnkfirst.repository.product;

import kr.co.bnkfirst.entity.product.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product,Integer> {
    @Query("""
    select p
    from Product p
    where (:pelgbl is null or p.pelgbl = :pelgbl)
      and (:prmthd is null or p.prmthd = :prmthd)
      and (:pprfcrt is null or p.pprfcrt = :pprfcrt)
    """)
    Page<Product> findDynamicProducts(
            @Param("pelgbl") String pelgbl,
            @Param("prmthd") String prmthd,
            @Param("pprfcrt") String pprfcrt,
            Pageable pageable
    );

    @Query("""
        select p
        from Product p
        where (:kw is null 
               or lower(p.pname) like lower(concat('%', :kw, '%')))
               and (:pelgbl is null or p.pelgbl = :pelgbl)
              and (:prmthd is null or p.prmthd = :prmthd)
              and p.pid != "BNK-TD-1"
    """)
    Page<Product> findPrefSorted(
            @Param("kw") String kw,               // (선택) 일반 검색어
            @Param("pelgbl") String pelgbl,
            @Param("prmthd") String prmthd,
            Pageable pageable
    );

    Optional<Product> findByPid(String pid);

    List<Product> findByPnameContainingIgnoreCaseOrPtypeContainingIgnoreCase(String pname, String ptype);

    //퇴직연금 상품 목록 조회 - 세현
    List<Product> findByPtype(String ptype);

}

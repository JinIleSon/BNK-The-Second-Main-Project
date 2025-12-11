package kr.co.bnkfirst.mapper;

import kr.co.bnkfirst.dto.BranchDTO;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface BranchMapper {

    /* ============================================
        1) 전체 조회 (TYPE TRIM)
       ============================================ */
    @Select("""
        SELECT 
            BRID,
            BRNAME,
            BRADDR,
            BRTEL,
            BRFAX,
            TRIM(TYPE) AS TYPE
        FROM BRANCH
        ORDER BY BRID ASC
    """)
    List<BranchDTO> findAllBranches();


    /* ============================================
        2) 페이징 조회
       ============================================ */
    @Select("""
        SELECT 
            BRID,
            BRNAME,
            BRADDR,
            BRTEL,
            BRFAX,
            TRIM(TYPE) AS TYPE
        FROM BRANCH
        ORDER BY BRID ASC
        OFFSET #{offset} ROWS
        FETCH NEXT #{size} ROWS ONLY
    """)
    List<BranchDTO> findBranchPage(
            @Param("offset") int offset,
            @Param("size")   int size
    );


    /* ============================================
        3) 총 개수
       ============================================ */
    @Select("SELECT COUNT(*) FROM BRANCH")
    int countBranches();


    /* ============================================
        4) 검색 기능 (NULL 안전 + TYPE 포함)
       ============================================ */
    @Select("""
        SELECT
            BRID,
            BRNAME,
            BRADDR,
            BRTEL,
            BRFAX,
            TRIM(TYPE) AS TYPE
        FROM BRANCH
        WHERE (
                LOWER(BRNAME) LIKE '%' || LOWER(#{keyword}) || '%'
             OR LOWER(BRADDR) LIKE '%' || LOWER(#{keyword}) || '%'
             OR LOWER(BRTEL)  LIKE '%' || LOWER(#{keyword}) || '%'
             OR LOWER(BRFAX)  LIKE '%' || LOWER(#{keyword}) || '%'
             OR LOWER(COALESCE(TYPE, '')) LIKE '%' || LOWER(#{keyword}) || '%'
             OR TO_CHAR(BRID) LIKE '%' || #{keyword} || '%'
        )
        ORDER BY BRID ASC
    """)
    List<BranchDTO> searchBranches(@Param("keyword") String keyword);


    /* ============================================
        5) 단일 조회
       ============================================ */
    @Select("""
        SELECT
            BRID,
            BRNAME,
            BRADDR,
            BRTEL,
            BRFAX,
            TRIM(TYPE) AS TYPE
        FROM BRANCH
        WHERE BRID = #{brid}
    """)
    BranchDTO findBranchById(@Param("brid") int brid);


    /* ============================================
        6) INSERT (TYPE TRIM 보정)
       ============================================ */
    @Insert("""
        INSERT INTO BRANCH 
        (BRID, BRNAME, BRADDR, BRTEL, BRFAX, TYPE)
        VALUES 
        (BRANCH_SEQ.NEXTVAL, #{brname}, #{braddr}, #{brtel}, #{brfax}, TRIM(#{type}))
    """)
    int insertBranch(BranchDTO dto);


    /* ============================================
        7) UPDATE (TYPE TRIM 보정)
       ============================================ */
    @Update("""
        UPDATE BRANCH
        SET 
            BRNAME = #{brname},
            BRADDR = #{braddr},
            BRTEL  = #{brtel},
            BRFAX  = #{brfax},
            TYPE   = TRIM(#{type})
        WHERE BRID = #{brid}
    """)
    int updateBranch(BranchDTO dto);


    /* ============================================
        8) DELETE
       ============================================ */
    @Delete("DELETE FROM BRANCH WHERE BRID = #{brid}")
    int deleteBranch(@Param("brid") int brid);
}

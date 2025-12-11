package kr.co.bnkfirst.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import java.time.LocalDate;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PFundPageRequestDTO {

    // 푸시용 주석
    @Builder.Default
    private int no = 1;

    @Builder.Default
    private int pg = 1;

    @Builder.Default
    private int size = 10;

    @Builder.Default
    private String boardType = "storelist";

    private String board_type2;
    private String board_type3;

    // 기간 필터 (로컬 날짜 기준)
    private LocalDate startDate; // inclusive
    private LocalDate endDate;   // inclusive
    private LocalDate endExclusive;

    private String searchType;
    private String keyword;

    private int offset;

    public int getOffset() {
        return (pg - 1) * size;
    }

    public Pageable getPageable(String sort){
        return PageRequest.of(this.pg - 1, this.size, Sort.by(sort).descending());
    }

    // 관리자 검색 필터
    private String mname;
    private String memail;
    private String mcond;
}

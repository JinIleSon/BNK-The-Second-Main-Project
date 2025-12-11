package kr.co.bnkfirst.dto.Info;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PageRequestDTO {
    private int page;   // 현재 페이지
    private int size;   // 페이지당 게시물 수

    public int getOffset() {
        return (page - 1) * size;
    }
}

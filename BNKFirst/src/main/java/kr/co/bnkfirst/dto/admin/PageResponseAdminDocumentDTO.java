package kr.co.bnkfirst.dto.admin;

import kr.co.bnkfirst.dto.DocumentDTO;
import kr.co.bnkfirst.dto.PageRequestDTO;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class PageResponseAdminDocumentDTO {
    private PageRequestDTO pageRequestDTO;
    private List<DocumentDTO> dtoList;
    private int total;

    // 필요하면 totalPages, isPrev, isNext 등 편의 필드들도 추가 가능
}

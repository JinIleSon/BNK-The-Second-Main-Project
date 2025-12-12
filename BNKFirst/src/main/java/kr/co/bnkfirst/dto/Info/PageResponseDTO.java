package kr.co.bnkfirst.dto.Info;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
public class PageResponseDTO<T> {
    private List<T> dtoList;
    private int total;
    private int page;
    private int size;
    private int totalPage;

    public PageResponseDTO(PageRequestDTO requestDTO, int total, List<T> dtoList) {
        this.dtoList = dtoList;
        this.total = total;
        this.page = requestDTO.getPage();
        this.size = requestDTO.getSize();
        this.totalPage = (int) Math.ceil((double) total / requestDTO.getSize());
    }
}

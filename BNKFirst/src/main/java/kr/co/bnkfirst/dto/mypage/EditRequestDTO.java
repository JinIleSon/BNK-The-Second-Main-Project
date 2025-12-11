package kr.co.bnkfirst.dto.mypage;

import kr.co.bnkfirst.dto.product.PcontractDTO;
import lombok.Data;

import java.util.List;

@Data
public class EditRequestDTO {
    private String pacc;
    private List<String> sellTypes;
    private List<PcontractDTO> products;
    private Long totalAmount;
}

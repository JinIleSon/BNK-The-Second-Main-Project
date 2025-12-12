package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.product.FundDTO;
import kr.co.bnkfirst.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class FundRestController {

    private final ProductService productService;

    @GetMapping("/product/fund/items")
    public Page<FundDTO> getFundItems(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "6") int pageSize,
            @RequestParam(required = false) String operator,
            @RequestParam(required = false) String grade,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String channel,
            @RequestParam(required = false) String keyword
    ) {
        Pageable pageable = PageRequest.of(page - 1, pageSize);
        return productService.findFunds(pageable, operator, grade, type, channel, keyword);
    }

    @GetMapping("/product/fund/detail")
    @ResponseBody
    public ResponseEntity<FundDTO> getFundDetail(@RequestParam("fid") String fid) {
        FundDTO dto = productService.getFundDetail(fid);
        if (dto == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(dto);
    }
}
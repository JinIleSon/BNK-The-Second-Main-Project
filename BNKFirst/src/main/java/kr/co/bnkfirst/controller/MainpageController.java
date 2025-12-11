package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.DocumentDTO;
import kr.co.bnkfirst.dto.MainEventDTO;
import kr.co.bnkfirst.dto.product.ProductDTO;
import kr.co.bnkfirst.service.DocumentService;
import kr.co.bnkfirst.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
@Slf4j
public class MainpageController {

    @Autowired
    private ProductService productService;

    @Autowired
    private DocumentService documentService;

    @GetMapping({"/main/main","/"})
    public String mainpage(Model model) {
        List<DocumentDTO> latestDocs = documentService.getLatestDocuments2();
        List<MainEventDTO> eventList = documentService.getMainEvents();

        model.addAttribute("latestDocs", latestDocs);
        model.addAttribute("events", eventList);

        return "main/main";
    }

    @ResponseBody
    @GetMapping("/main/search")
    public List<ProductDTO> searchProducts(@RequestParam("keyword") String keyword) {
        log.info("검색요청 keyword = {}", keyword);

        List<ProductDTO> products = productService.searchProducts(keyword);

        log.info("검색 결과 개수 = {}", products.size());
        for (ProductDTO p : products) {
            log.info("상품명: {}, 유형: {}, 금리: {}~{}",
                    p.getPname(), p.getPtype(), p.getPbirate(), p.getPhirate());
        }
        return products;
    }

    @GetMapping("/docs/test")
    @ResponseBody
    public List<MainEventDTO> testLatestDocs() {
        return documentService.getMainEvents();
    }

}

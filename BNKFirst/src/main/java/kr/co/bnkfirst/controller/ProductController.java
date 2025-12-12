package kr.co.bnkfirst.controller;

import jakarta.annotation.security.PermitAll;
import kr.co.bnkfirst.dto.UsersDTO;
import kr.co.bnkfirst.dto.product.PcontractDTO;
import kr.co.bnkfirst.dto.product.ProductDTO;
import kr.co.bnkfirst.dto.product.SlfcertDTO;
import kr.co.bnkfirst.service.MypageService;
import kr.co.bnkfirst.service.ProductService;
import kr.co.bnkfirst.service.SlfcertService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.ErrorResponseException;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Map;
import java.util.Optional;

/*
    이름 : 강민철, 손진일
    날짜 : 2025.11.21.
    내용 : 상품 페이지 컨트롤러
 */

@Slf4j
@Controller
@RequiredArgsConstructor
public class ProductController {
    private final ProductService productService;
    private final SlfcertService slfcertService;
    private final MypageService mypageService;

    @GetMapping("/product/main")
    public String mainPage() {
        return "product/product_main";
    }

    @GetMapping("/product/list")
    public String listPage() {
        return "product/product_list";
    }

    @PermitAll
    @ResponseBody
    @GetMapping("/product/items")
    public ResponseEntity<Page<ProductDTO>> getItems(@RequestParam(defaultValue = "1") int page,
                                                     @RequestParam(defaultValue = "6") int pageSize,
                                                     @RequestParam(required = false) String target,
                                                     @RequestParam(required = false) String join,
                                                     @RequestParam(required = false) String keyword) {
//        log.info("args = {}, {}, {}, {}, {}, {}. {}", sort, page, pageSize,target, join, tax, keyword);
        Pageable pageable = PageRequest.of(page-1,pageSize, Sort.by("pbirate").descending());
        Page<ProductDTO> products = productService.findProducts(pageable,target, join, keyword);
        log.info("products total {}", products.getTotalElements());
        return ResponseEntity.ok(products);
    }

    @GetMapping("/product/view/{pid}")
    public String viewPage(@PathVariable String pid, Model model) {
        model.addAttribute("pid", pid);
        return "product/product_view";
    }

    @ResponseBody
    @GetMapping("/product/details/{pid}")
    public ResponseEntity<Optional<ProductDTO>> getProductDetails(@PathVariable String pid, Model model) {
        Optional<ProductDTO> dtoOptional = productService.findProductByPid(pid);
        if(dtoOptional.isPresent()) {
            return ResponseEntity.ok(dtoOptional);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }

    @GetMapping("/product/insertInfo/{pid}")
    public String insertInfoPage(Model model, Principal principal, @PathVariable String pid) {
        if (principal == null) {
            throw new ErrorResponseException(HttpStatus.FORBIDDEN); // 비로그인시 403
        }
        String mid = principal.getName();
        log.info("mid {}", mid);
        boolean isExist = slfcertService.countSlfcertByMid(mid);
        UsersDTO userInfo = mypageService.findById(mid);
        model.addAttribute("mid", mid);
        model.addAttribute("pid", pid);
        model.addAttribute("hasInfo", isExist ? "true" : "false");
        model.addAttribute("userInfo", userInfo);
        return "product/product_insert_info";
    }

    @PostMapping("/api/slfcert")
    public ResponseEntity<SlfcertDTO> slfcertForm(SlfcertDTO slfcertDTO, Principal principal) {
        log.info("slfcert {}", slfcertDTO);
        String cusid = principal.getName();
        log.info("cusid {}", cusid);
        slfcertDTO.setCusid(cusid);
        boolean isExist = slfcertService.countSlfcertByMid(cusid);
        if (isExist) {
            log.info("slfcert already exist");
            return ResponseEntity.status(HttpStatus.CONFLICT).build(); // Conflict : 409
        }
        SlfcertDTO saved = slfcertService.saveSlfcert(slfcertDTO);
        if(saved == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        } else if (saved.getCusid().equals(cusid)) {
            return ResponseEntity.ok(slfcertDTO);
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).build(); // Bad Request : 400
    }

    @GetMapping("/api/slfcert/{mid}")
    public ResponseEntity<Void> chkSlfcertExist(@PathVariable String mid) {
        // 로그인 기능 구현 전까지 임시 데이터 주입
        boolean exists = slfcertService.countSlfcertByMid(mid);
        return exists ? ResponseEntity.ok().build() : ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }

    @GetMapping("/api/account/{type}")
    public ResponseEntity<PcontractDTO> getAcc(@PathVariable String type, Principal principal) {
        if (principal == null) {
            throw new ErrorResponseException(HttpStatus.FORBIDDEN); // 비로그인시 403
        }
        String uid = principal.getName();
        log.info("getACC uid {}", uid);
        PcontractDTO acc = productService.getAccount(uid, type);
        return ResponseEntity.ok(acc);
    }

    @PostMapping("/api/account/verify-pin")
    public ResponseEntity<Boolean> checkAccPass(Principal principal, @RequestBody Map<String, String> body) {
        if (principal == null) {
            throw new ErrorResponseException(HttpStatus.FORBIDDEN);
        }
        String uid = principal.getName();
        String accountNo = body.get("pacc");
        String pin =  body.get("pin");
        String type = body.get("type");
        log.info("pacc: {}, pin: {}", accountNo, pin);
        Boolean valid = productService.checkAccPin(accountNo, pin, uid, type);
        log.info("valid: {}", valid);
        return ResponseEntity.ok(valid);
    }

    @PostMapping("/api/product/buy")
    public ResponseEntity<Boolean> buyProduct(Principal principal, @RequestBody PcontractDTO pcontractDTO) {
        if (principal == null) {
            throw new ErrorResponseException(HttpStatus.FORBIDDEN);
        }
        String uid = principal.getName();
        log.info("buyProduct uid {}", uid);
        log.info("buyProduct PcontractDTO: {}", pcontractDTO);
        boolean checkSaved = productService.buyProduct(uid, pcontractDTO);
        log.info("checkSaved: {}", checkSaved);
        return ResponseEntity.ok(checkSaved);
    }

    @GetMapping("/product/subCmpl/list")
    public String subCmplPage(Model model, @RequestParam String pid, Principal principal) {
        if (principal == null) {
            throw new ErrorResponseException(HttpStatus.FORBIDDEN);
        }
        String mid = principal.getName();
        model.addAttribute("mid", mid);
        model.addAttribute("pcpid", pid);
        log.info("subCmplPage pid {}", pid);
        return "product/product_sub_cmpl";
    }


    @GetMapping("/product/subCmpl")
    public ResponseEntity<PcontractDTO> subCmplPage(
                                                    @RequestParam("mid") String mid,
                                                    @RequestParam("pcpid") String pcpid) {

        return ResponseEntity.ok(productService.resultPcontract(mid, pcpid));
    }
}

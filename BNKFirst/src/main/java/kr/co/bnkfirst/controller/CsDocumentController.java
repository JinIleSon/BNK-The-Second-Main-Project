package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.DocumentDTO;
import kr.co.bnkfirst.service.DocumentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@Controller
@RequestMapping("/api/document")
@RequiredArgsConstructor
public class CsDocumentController {

    private final DocumentService documentService;

    /**Q&A JSON 데이터 반환용 (fetch에서 사용)*/
    @GetMapping("/list")
    @ResponseBody
    public List<DocumentDTO> getDocuments(@RequestParam(defaultValue = "Q&A") String type) {
        return documentService.getAllDocuments(type);
    }

    /**필요서류 페이지*/
    @GetMapping("/cs/consultation/document")
    public String documentPage(@RequestParam(defaultValue = "필요서류") String type, Model model) {
        List<DocumentDTO> docs = documentService.getAllDocuments(type);
        model.addAttribute("docs", docs);
        return "cs/consultation/document/cs_document";
    }

    /**Q&A 페이지*/
    @GetMapping("/cs/consultation/qna")
    public String qnaPage(@RequestParam(defaultValue = "Q&A") String type, Model model) {
        List<DocumentDTO> qna = documentService.getAllDocuments(type);
        model.addAttribute("qna", qna);
        return "cs/consultation/Q&A/cs_qna";
    }

    @PostMapping("/add")
    @ResponseBody
    public ResponseEntity<String> addQna(@RequestBody DocumentDTO dto){
        documentService.insertDocument(dto);
        return ResponseEntity.ok("등록완료");
    }

    /**서식/약관/자료실 예금 페이지*/
    @GetMapping("/cs/data_room/deposit")
    public String depositPage(@RequestParam(defaultValue = "") String type, Model model) {
        List<DocumentDTO> deposit = documentService.getAllDocuments(type);
        model.addAttribute("deposit", deposit);
        return "cs/data_room/deposit/deposit";
    }

    /**검색 기능 (AJAX 호출 시 JSON 반환)*/
    @GetMapping("/search")
    @ResponseBody
    public List<DocumentDTO> searchDocuments(@RequestParam String keyword) {
        log.info("문서 검색 요청 keyword={}", keyword);
        return documentService.searchDocuments(keyword);
    }
}

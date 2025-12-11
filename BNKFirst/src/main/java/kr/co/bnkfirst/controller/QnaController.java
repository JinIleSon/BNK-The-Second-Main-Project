package kr.co.bnkfirst.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@Slf4j
@RequiredArgsConstructor
public class QnaController {

    @GetMapping("/qna/main")
    public String qnaMain(){
        return "qna/qna_main";
    }
}

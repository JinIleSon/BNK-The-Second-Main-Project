package kr.co.bnkfirst.controller;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ChatbotController {
    @GetMapping("/components/chatbot_test")
    public String chatbotTest() {
        return "components/chatbot_test"; // templates/components/chatbot_test.html
    }
}
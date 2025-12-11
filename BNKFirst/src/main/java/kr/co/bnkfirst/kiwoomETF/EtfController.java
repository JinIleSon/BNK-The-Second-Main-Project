package kr.co.bnkfirst.kiwoomETF;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class EtfController {

    private final EtfService etfService;

    @GetMapping("/api/etf")
    public List<EtfQuoteDTO> getEtfQuotes() {
        return etfService.getEtfRanks();
    }
}
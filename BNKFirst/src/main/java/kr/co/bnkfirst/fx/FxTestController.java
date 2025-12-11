package kr.co.bnkfirst.fx;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/api/fx")
@RequiredArgsConstructor
public class FxTestController {

    private final KoreaEximFxClient fxClient;

    // GET /api/fx/test        -> 오늘 기준 환율
    // GET /api/fx/test?date=20241123  -> 해당 날짜 기준 환율
    @GetMapping("/test")
    public ResponseEntity<String> test(@RequestParam(required = false) String date) {
        LocalDate targetDate;

        if (date == null || date.isBlank()) {
            targetDate = LocalDate.now();
        } else {
            // yyyyMMdd 형식으로 들어온다고 가정
            targetDate = LocalDate.parse(date, DateTimeFormatter.BASIC_ISO_DATE);
        }

        String json = fxClient.getRatesRaw(targetDate);
        return ResponseEntity.ok(json);
    }
}

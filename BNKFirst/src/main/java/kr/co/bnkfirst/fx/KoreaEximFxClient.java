package kr.co.bnkfirst.fx;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Component
@RequiredArgsConstructor
@Slf4j
public class KoreaEximFxClient {

    private final RestTemplate restTemplate;

    @Value("${koreaexim.base-url}")
    private String baseUrl;

    @Value("${koreaexim.auth-key}")
    private String authKey;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.BASIC_ISO_DATE; // yyyyMMdd

    /**
     * 수출입은행 현재환율 API raw JSON 문자열 그대로 반환
     * - date != null  : 해당 날짜 기준 환율 (searchdate 파라미터 사용)
     * - date == null : searchdate 없이 호출 → 가장 최근 영업일 기준 환율
     */
    public String getRatesRaw(LocalDate date) {
        String searchDate = date.format(DATE_FMT);

        String url = UriComponentsBuilder.fromHttpUrl(baseUrl)
                .queryParam("authkey", authKey)
                .queryParam("searchdate", searchDate)
                .queryParam("data", "AP01")
                .toUriString();

        return restTemplate.getForObject(url, String.class);
    }

}

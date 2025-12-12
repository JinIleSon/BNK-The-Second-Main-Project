package kr.co.bnkfirst.kiwoom;

import java.util.List;
import java.util.Map;

public interface KiwoomTrClient {
    /**
     * @param trCode    예: "opt10080"
     * @param blockName 예: "주식분봉차트"
     * @param input     TR 입력값 맵
     * @param limit     최대 row 개수 (300)
     * @return          각 row 를 FID/컬럼이름 기준으로 담은 맵
     */
    List<Map<String, String>> call(String trCode,
                                   String blockName,
                                   Map<String, String> input,
                                   int limit);
}

package kr.co.bnkfirst.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PensionAssetResult {

    // 입력 그대로 보여줄 용도
    private int currentAge;
    private int retireAge;
    private Integer pensionYears;

    // 현재 보유자산
    private Long currentAsset;      // 원
    private Long currentAssetMan;   // 만원

    // 연금 개시시점 자산
    private Long retirementAsset;     // 원
    private Long retirementAssetMan;  // 만원

    // 매월 연금 수령 금액
    private Long monthlyPension;    // 원
}

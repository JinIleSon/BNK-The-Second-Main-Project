package kr.co.bnkfirst.dto;

import lombok.Data;

@Data
public class PensionAssetRequest {
    // 02. 현재 나이 / 은퇴나이
    private int currentAge;              // th:field="*{currentAge}"
    private int retireAge;               // th:field="*{retireAge}"

    // 03. 수령기간 / 현재 보유자산
    private Integer pensionYears;        // th:field="*{pensionYears}"
    private Long currentAssetMan;        // th:field="*{currentAssetMan}"  (단위: 만원)

    // 04. 운용수익률 / 연금부리이율
    private Double investAnnualRatePercent;   // th:field="*{investAnnualRatePercent}"
    private Double pensionAnnualRatePercent;  // th:field="*{pensionAnnualRatePercent}"
}

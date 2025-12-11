package kr.co.bnkfirst.domain;

import lombok.Data;

@Data
public class Contribution {
    private Long contriId;
    private Long empId;
    private String yearMonth;
    private Long amount;

    // 누적 적립금 계산용 (DB가 아니라 서비스에서 계산해서 넣음)
    private Long totalAmount;
}

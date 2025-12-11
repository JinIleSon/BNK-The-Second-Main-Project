package kr.co.bnkfirst.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DocumentDTO {

    private int docid;
    private String mid;
    private String doctype;
    private String doctitle;
    private String docanswer;
    private String docfile;
    private LocalDateTime docupdate;
    private String doccontent;
    private String docgroup;

    // 추가 필드 - 손진일
    private String mname;
}

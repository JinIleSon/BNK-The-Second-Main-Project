package kr.co.bnkfirst.dto.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SvgUploadResultDTO {

    private boolean ok;
    private String msg;
    private long version; // 캐시 무력화용 타임스탬프

}

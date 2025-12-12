package kr.co.bnkfirst.dto.Info;

import lombok.Data;
import java.time.LocalDate;

@Data
public class EventDTO {

    private int eventId;           // 식별번호
    private String title;          // 제목
    private String content;        // 내용
    private String thumbnail;      // 썸네일 경로
    private LocalDate startDate;   // 시작일
    private LocalDate endDate;     // 종료일
    private String status;         // 상태 (예: 진행중, 종료)
    private String summary;        // 요약문
    private LocalDate regDate;     // 등록일
    private boolean isNew;         // 신규 게시물 여부

    /** ✅ 요약 내용 자동 생성 */
    public String getSummary() {
        if (summary != null && !summary.isEmpty()) {
            return summary;
        }
        return (content != null && content.length() > 60)
                ? content.substring(0, 60) + "..."
                : content;
    }

    /** ✅ 최근 등록된 글이면 NEW 표시 */
    public boolean isNew() {
        if (regDate == null) return false;
        return regDate.isAfter(LocalDate.now().minusDays(7));
    }

    /** ✅ 썸네일이 없을 경우 기본 이미지 경로 반환 */
    public String getThumbnail() {
        if (thumbnail == null || thumbnail.isBlank()) {
            // static/images/default_event.jpg 가 기본 이미지라 가정
            return "/images/default_event.jpg";
        }
        return thumbnail;
    }
}

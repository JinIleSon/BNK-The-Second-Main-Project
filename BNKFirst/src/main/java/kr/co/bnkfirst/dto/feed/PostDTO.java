package kr.co.bnkfirst.dto.feed;

import lombok.*;
import java.time.LocalDateTime;

/*
    날짜 : 2025.12.24 / 2025.12.30
    이름 : 이준우
    내용 : 게시글 DTO
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PostDTO {

    // DB 컬럼 (POST TABLE)

    private Long postid;
    private Long authoruId;
    private String posttype;
    private String market;
    private String title;
    private String body;
    private String coverurl;
    private String status;
    private Long viewcount;

    private LocalDateTime createdat;
    private LocalDateTime updatedat;

    // 조회 확장(조인/집계)
    private String authornickname;
    private String authoravatarurl;

    private Long likecount;
    private Long commentcount;
}
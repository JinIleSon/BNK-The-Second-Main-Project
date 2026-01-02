package kr.co.bnkfirst.dto.feed;

import lombok.Data;
import java.time.LocalDateTime;

/*
    날짜 : 2026.01.02
    이름 : 이준우
    내용 : 게시글 댓글 작업 시작
 */

@Data
public class PostCommentDTO {
    private Long commentId;
    private Long postId;
    private Long uId;
    private String body;
    private String status;
    private LocalDateTime createdAt;

    // 조인으로 내려줄(optional join fields)
    private String nickname;
    private String avatarUrl;

    // 프론트 편의용(UI helper)
    private Boolean mine;
}

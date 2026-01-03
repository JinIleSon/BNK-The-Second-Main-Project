package kr.co.bnkfirst.dto.feed;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.ToString;

/*
  내용 : 내 댓글 목록 아이템 DTO (원글 정보 포함)
*/
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class MyCommentItemDTO {
    private Long commentId;
    private Long postId;
    private String postTitle;
    private String body;
    private LocalDateTime createdAt;
}

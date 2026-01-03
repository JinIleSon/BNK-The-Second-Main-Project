package kr.co.bnkfirst.dto.feed;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.ToString;

/*
  내용 : 내 게시글 목록 아이템 DTO
*/
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class MyPostItemDTO {
    private Long postId;
    private String title;
    private String body;
    private LocalDateTime createdAt;
}
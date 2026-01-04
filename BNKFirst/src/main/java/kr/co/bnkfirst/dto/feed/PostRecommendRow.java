package kr.co.bnkfirst.dto.feed;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class PostRecommendRow {
    private Long postId;
    private Long authorUid;
    private String postType;
    private String title;
    private String body;
    private String coverUrl;
    private String status;
    private LocalDateTime createdAt;

    private Long likeCount;
    private Integer likedByMe;
}
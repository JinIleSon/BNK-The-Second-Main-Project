package kr.co.bnkfirst.dto.feed;

import lombok.*;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PostListResponse {
    private List<PostDTO> items;
    private Long nextLastPostId;
    private boolean hasNext;
}

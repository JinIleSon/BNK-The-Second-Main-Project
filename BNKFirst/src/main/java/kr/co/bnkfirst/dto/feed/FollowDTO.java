package kr.co.bnkfirst.dto.feed;

/*
    날짜 : 2025.01.04
    이름 : 이준우
    내용 : Follow DTO
 */

import lombok.*;
import java.sql.Timestamp;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FollowDTO {
    private Long followerUid;
    private Long followingUid;
    private Timestamp createdAt;
}

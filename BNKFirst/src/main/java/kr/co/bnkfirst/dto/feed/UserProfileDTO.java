package kr.co.bnkfirst.dto.feed;

/*
    날짜 : 2025.12.24, 01.03
    이름 : 이준우
    내용 : 사용자 프로필 DTO, 작업 시작
 */

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileDTO {
    private Long uId;
    private String nickname;
    private String avatarUrl;
    private String bio;
    private LocalDateTime uptat;
}
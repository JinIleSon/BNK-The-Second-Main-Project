package kr.co.bnkfirst.dto.feed;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.ToString;

/*
  내용 : 프로필 화면 응답용 DTO (프로필 + 카운트)
*/
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileViewDTO {
    private UserProfileDTO profile;
    private int postCount;
    private int commentCount;
    private int likeCount;
}
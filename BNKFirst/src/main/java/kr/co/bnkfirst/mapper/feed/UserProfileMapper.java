package kr.co.bnkfirst.mapper.feed;

import java.util.List;

import kr.co.bnkfirst.dto.feed.MyCommentItemDTO;
import kr.co.bnkfirst.dto.feed.MyLikeItemDTO;
import kr.co.bnkfirst.dto.feed.MyPostItemDTO;
import kr.co.bnkfirst.dto.feed.UserProfileDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/*
    날짜 : 2025.12.24, 01.03
    이름 : 이준우
    내용 : 유저프로필 DB 호출 인터페이스
 */

@Mapper
public interface UserProfileMapper {

    UserProfileDTO selectByUid(@Param("uId") Long uId);

    int insertDefault(@Param("uId") Long uId);

    int updateProfile(UserProfileDTO dto);

    int countMyPosts(@Param("uId") Long uId);
    int countMyComments(@Param("uId") Long uId);
    int countMyLikes(@Param("uId") Long uId);

    List<MyPostItemDTO> selectMyPosts(
            @Param("uId") Long uId,
            @Param("size") int size,
            @Param("lastPostId") Long lastPostId
    );

    List<MyCommentItemDTO> selectMyComments(
            @Param("uId") Long uId,
            @Param("size") int size,
            @Param("lastCommentId") Long lastCommentId
    );

    List<MyLikeItemDTO> selectMyLikedPosts(
            @Param("uId") Long uId,
            @Param("size") int size,
            @Param("lastLikeId") Long lastLikeId
    );
}
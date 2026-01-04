package kr.co.bnkfirst.mapper.feed;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface FollowMapper {

    int upsertFollow(@Param("followerUid") long followerUid,
                     @Param("followingUid") long followingUid);

    int deleteFollow(@Param("followerUid") long followerUid,
                     @Param("followingUid") long followingUid);

    int existsFollow(@Param("followerUid") long followerUid,
                     @Param("followingUid") long followingUid);

    int countFollowing(@Param("uid") long uid);
    int countFollowers(@Param("uid") long uid);
}

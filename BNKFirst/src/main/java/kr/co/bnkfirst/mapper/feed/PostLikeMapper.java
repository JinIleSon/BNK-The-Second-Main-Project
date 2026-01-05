package kr.co.bnkfirst.mapper.feed;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PostLikeMapper {
    int exists(@Param("postId") long postId, @Param("uId") long uId);
    int insert(@Param("postId") long postId, @Param("uId") long uId);
    int delete(@Param("postId") long postId, @Param("uId") long uId);
    long countByPostId(@Param("postId") long postId);
    long countByUserId(@Param("uId") Long uId);
}
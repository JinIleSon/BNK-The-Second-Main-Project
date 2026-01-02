package kr.co.bnkfirst.mapper.feed;

import kr.co.bnkfirst.dto.feed.PostCommentDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PostCommentMapper {

    List<PostCommentDTO> selectByPostId(
            @Param("postId") long postId,
            @Param("size") int size,
            @Param("lastCommentId") Long lastCommentId
    );

    int insertComment(
            @Param("postId") long postId,
            @Param("uId") long uId,
            @Param("body") String body
    );

    int updateBodyByOwner(
            @Param("commentId") long commentId,
            @Param("uId") long uId,
            @Param("body") String body
    );

    int softDeleteByOwner(
            @Param("commentId") long commentId,
            @Param("uId") long uId
    );
}

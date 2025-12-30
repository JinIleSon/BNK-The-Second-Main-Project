package kr.co.bnkfirst.mapper.feed;

import kr.co.bnkfirst.dto.feed.PostDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/*
    날짜 : 2025.12.24
    이름 : 이준우
    내용 : 게시글/좋아요/댓글 DB 호출 인터페이스
 */

@Mapper
public interface PostMapper {

    List<PostDTO> selectPostList(
            @Param("posttype") String posttype,
            @Param("lastPostId") Long lastPostId,
            @Param("size") int size
    );

    PostDTO selectPostDetail(
            @Param("postid") Long postid,
            @Param("posttype") String posttype
    );

    int increaseViewCount(@Param("postid") Long postid);

    int insertPost(PostDTO dto);

    long selectPostCurrval();

    int updatePost(PostDTO dto);

    int softDeletePost(
            @Param("postid") Long postid,
            @Param("authoruId") Long authoruId,
            @Param("posttype") String posttype
    );
}
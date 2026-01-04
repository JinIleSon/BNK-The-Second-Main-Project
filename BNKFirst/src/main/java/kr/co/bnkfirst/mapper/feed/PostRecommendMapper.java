package kr.co.bnkfirst.mapper.feed;

import kr.co.bnkfirst.dto.feed.PostRecommendRow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PostRecommendMapper {
    List<PostRecommendRow> selectRecommend(@Param("uId") Long uId, @Param("size") int size);
}

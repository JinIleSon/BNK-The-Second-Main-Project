package kr.co.bnkfirst.service.feed;

import kr.co.bnkfirst.dto.feed.PostRecommendRow;
import kr.co.bnkfirst.mapper.feed.PostRecommendMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PostRecommendService {
    private final PostRecommendMapper mapper;

    public PostRecommendService(PostRecommendMapper mapper) {
        this.mapper = mapper;
    }

    public List<PostRecommendRow> recommend(Long uId, int size) {
        return mapper.selectRecommend(uId, size);
    }
}

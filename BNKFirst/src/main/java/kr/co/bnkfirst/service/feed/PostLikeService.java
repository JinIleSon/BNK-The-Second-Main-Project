package kr.co.bnkfirst.service.feed;

import kr.co.bnkfirst.dto.feed.ToggleLikeResult;
import kr.co.bnkfirst.mapper.feed.PostLikeMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PostLikeService {
    private final PostLikeMapper postLikeMapper;

    public PostLikeService(PostLikeMapper postLikeMapper) {
        this.postLikeMapper = postLikeMapper;
    }

    @Transactional
    public ToggleLikeResult toggle(long postId, long uId) {
        int exists = postLikeMapper.exists(postId, uId);
        boolean liked;

        if (exists == 1) {
            postLikeMapper.delete(postId, uId);
            liked = false;
        } else {
            postLikeMapper.insert(postId, uId);
            liked = true;
        }

        long likeCount = postLikeMapper.countByPostId(postId);
        return new ToggleLikeResult(liked, likeCount);
    }
}
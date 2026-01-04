package kr.co.bnkfirst.service.feed;

import kr.co.bnkfirst.mapper.feed.FollowMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class FollowService {

    private final FollowMapper followMapper;

    @Transactional
    public void follow(long meUid, long targetUid) {
        if (meUid == targetUid) throw new IllegalArgumentException("self follow not allowed");
        followMapper.upsertFollow(meUid, targetUid);
    }

    @Transactional
    public void unfollow(long meUid, long targetUid) {
        followMapper.deleteFollow(meUid, targetUid);
    }

    public boolean isFollowing(long meUid, long targetUid) {
        return followMapper.existsFollow(meUid, targetUid) > 0;
    }

    public Map<String, Integer> counts(long uid) {
        return Map.of(
                "following", followMapper.countFollowing(uid),
                "followers", followMapper.countFollowers(uid)
        );
    }
}
package kr.co.bnkfirst.controller.feed;

import kr.co.bnkfirst.security.LoginUidProvider;
import kr.co.bnkfirst.service.feed.FollowService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/follow")
public class FollowController {

    private final FollowService followService;
    private final LoginUidProvider loginUidProvider;

    @PostMapping("/{targetUid}")
    public Map<String, Object> follow(@PathVariable long targetUid) {
        long meUid = loginUidProvider.requireUid();
        followService.follow(meUid, targetUid);
        return Map.of("ok", true);
    }

    @DeleteMapping("/{targetUid}")
    public Map<String, Object> unfollow(@PathVariable long targetUid) {
        long meUid = loginUidProvider.requireUid();
        followService.unfollow(meUid, targetUid);
        return Map.of("ok", true);
    }

    @GetMapping("/check/{targetUid}")
    public Map<String, Object> check(@PathVariable long targetUid) {
        Long meUid = loginUidProvider.optionalUidOrNull();
        boolean following = (meUid != null) && followService.isFollowing(meUid, targetUid);
        return Map.of("following", following);
    }

    @GetMapping("/count/{uid}")
    public Map<String, Integer> count(@PathVariable long uid) {
        return followService.counts(uid);
    }
}
package kr.co.bnkfirst.controller.feed;

import kr.co.bnkfirst.dto.feed.ToggleLikeResult;
import kr.co.bnkfirst.security.LoginUidProvider;
import kr.co.bnkfirst.service.feed.PostLikeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/post")
public class PostLikeController {
    private final PostLikeService postLikeService;
    private final LoginUidProvider loginUidProvider;

    public PostLikeController(PostLikeService postLikeService, LoginUidProvider loginUidProvider) {
        this.postLikeService = postLikeService;
        this.loginUidProvider = loginUidProvider;
    }

    @PostMapping("/{postId}/like")
    public ResponseEntity<?> toggleLike(@PathVariable long postId) {
        long uId = loginUidProvider.requireUid();
        ToggleLikeResult r = postLikeService.toggle(postId, uId);
        return ResponseEntity.ok(r);
    }
}
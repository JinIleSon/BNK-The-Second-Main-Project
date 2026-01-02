package kr.co.bnkfirst.controller.feed;

import kr.co.bnkfirst.dto.feed.CommentBodyRequest;
import kr.co.bnkfirst.dto.feed.PostCommentDTO;
import kr.co.bnkfirst.security.LoginUidProvider;
import kr.co.bnkfirst.service.feed.PostCommentService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api")
public class PostCommentController {

    private final PostCommentService postCommentService;
    private final LoginUidProvider loginUidProvider;

    @GetMapping("/posts/{postId}/comments")
    public List<PostCommentDTO> list(@PathVariable long postId,
                                     @RequestParam(defaultValue="20") int size,
                                     @RequestParam(required=false) Long lastCommentId) {
        Long loginUid = loginUidProvider.optionalUidOrNull();
        return postCommentService.list(postId, size, lastCommentId, loginUid);
    }

    @PostMapping("/posts/{postId}/comments")
    public Map<String,Object> create(@PathVariable long postId,
                                     @RequestBody CommentBodyRequest req) {
        long loginUid = loginUidProvider.requireUid();
        postCommentService.create(postId, loginUid, req.getBody());
        return Map.of("ok", true);
    }

    @PutMapping("/comments/{commentId}")
    public Map<String,Object> update(@PathVariable long commentId,
                                     @RequestBody CommentBodyRequest req) {
        long loginUid = loginUidProvider.requireUid();
        postCommentService.update(commentId, loginUid, req.getBody());
        return Map.of("ok", true);
    }

    @DeleteMapping("/comments/{commentId}")
    public Map<String,Object> delete(@PathVariable long commentId) {
        long loginUid = loginUidProvider.requireUid();
        postCommentService.delete(commentId, loginUid);
        return Map.of("ok", true);
    }
}

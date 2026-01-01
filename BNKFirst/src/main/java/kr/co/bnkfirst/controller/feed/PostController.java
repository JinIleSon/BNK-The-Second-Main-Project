package kr.co.bnkfirst.controller.feed;

/*
    날짜 : 2025.12.24
    이름 : 이준우
    내용 : 게시글/좋아요/댓글 Controller
 */

import jakarta.servlet.http.HttpServletRequest;
import kr.co.bnkfirst.dto.feed.PostDTO;
import kr.co.bnkfirst.dto.feed.PostListResponse;
import kr.co.bnkfirst.service.feed.PostService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/post")
public class PostController {

    private final PostService postService;

    public PostController(PostService postService) {
        this.postService = postService;
    }

    //  커뮤니티(BOARD) - 운영용

    // 커뮤니티 목록(무한스크롤)
    // GET /api/post/board?size=20&lastPostId=123
    @GetMapping("/board")
    public ResponseEntity<PostListResponse> boardList(
            @RequestParam(required = false) Long lastPostId,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(postService.listBoard(lastPostId, size));
    }

    // 커뮤니티 상세(+조회수 증가)
    @GetMapping("/board/{postId}")
    public ResponseEntity<PostDTO> boardDetail(
            @PathVariable Long postId,
            @RequestParam(defaultValue = "true") boolean view
    ) {
        return ResponseEntity.ok(postService.detailBoard(postId, view));
    }

    // 커뮤니티 작성
    @PostMapping("/board")
    public ResponseEntity<?> boardCreate(@RequestBody PostDTO req, HttpServletRequest request) {
        Long uid = resolveUid(request);
        Long newId = postService.createBoard(req, uid);
        return ResponseEntity.ok(newId);
    }

    // 커뮤니티 수정(작성자만)
    @PutMapping("/board/{postId}")
    public ResponseEntity<?> boardUpdate(
            @PathVariable Long postId,
            @RequestBody PostDTO req,
            HttpServletRequest request
    ) {
        Long uid = resolveUid(request);
        postService.updateBoard(postId, req, uid);
        return ResponseEntity.ok().build();
    }

    // 커뮤니티 삭제(작성자만, 소프트 삭제)
    @DeleteMapping("/board/{postId}")
    public ResponseEntity<?> boardDelete(
            @PathVariable Long postId,
            HttpServletRequest request
    ) {
        Long uid = resolveUid(request);
        postService.deleteBoard(postId, uid);
        return ResponseEntity.ok().build();
    }

    // 로그인 UID 추출 (세션/JWT 혼합 대비)
    private Long resolveUid(HttpServletRequest request) {
        // 1) 세션 uId
        try {
            if (request.getSession(false) != null) {
                Object v = request.getSession(false).getAttribute("uId");
                Long uid = toLong(v);
                if (uid != null) return uid;
            }
        } catch (Exception ignored) {}

        // 2) 개발용 헤더(Flutter 빨리 붙일 때)
        try {
            Long uid = toLong(request.getHeader("X-UID"));
            if (uid != null) return uid;
        } catch (Exception ignored) {}

        return null;
    }

    private Long toLong(Object v) {
        if (v == null) return null;
        if (v instanceof Long) return (Long) v;
        if (v instanceof Integer) return ((Integer) v).longValue();
        if (v instanceof String s) {
            if (s.isBlank()) return null;
            try { return Long.parseLong(s.trim()); } catch (Exception e) { return null; }
        }
        return null;
    }

    @GetMapping("/{posttype}/{postid}")
    public PostDTO detail(@PathVariable String posttype,
                          @PathVariable Long postid) {
        return postService.getPostDetail(postid, posttype.toUpperCase());
    }

}

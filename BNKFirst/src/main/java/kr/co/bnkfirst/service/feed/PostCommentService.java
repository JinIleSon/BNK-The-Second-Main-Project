package kr.co.bnkfirst.service.feed;

import kr.co.bnkfirst.dto.feed.PostCommentDTO;
import kr.co.bnkfirst.mapper.feed.PostCommentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PostCommentService {

    private final PostCommentMapper postCommentMapper;

    // GET /posts/{postId}/comments
    public List<PostCommentDTO> list(long postId, int size, Long lastCommentId, Long loginUidOrNull) {
        int safeSize = Math.min(Math.max(size, 1), 50);

        List<PostCommentDTO> list = postCommentMapper.selectByPostId(postId, safeSize, lastCommentId);

        // mine 플래그 + 삭제 마스킹(운영 안전)
        for (PostCommentDTO c : list) {
            boolean mine = (loginUidOrNull != null && loginUidOrNull.equals(c.getUId()));
            c.setMine(mine);

            if ("DELETED".equalsIgnoreCase(c.getStatus())) {
                c.setBody("삭제된 댓글입니다.");
            }
        }
        return list;
    }

    // POST /posts/{postId}/comments
    public void create(long postId, long loginUid, String body) {
        String safe = (body == null) ? "" : body.trim();

        if (safe.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "EMPTY_BODY");
        }
        if (safe.length() > 1000) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "BODY_TOO_LONG");
        }

        int ok = postCommentMapper.insertComment(postId, loginUid, safe);
        if (ok != 1) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "INSERT_FAILED");
        }
    }

    // PUT /comments/{commentId}
    public void update(long commentId, long loginUid, String body) {
        String safe = (body == null) ? "" : body.trim();

        if (safe.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "EMPTY_BODY");
        }
        if (safe.length() > 1000) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "BODY_TOO_LONG");
        }

        int ok = postCommentMapper.updateBodyByOwner(commentId, loginUid, safe);
        if (ok != 1) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "NOT_OWNER_OR_NOT_ACTIVE");
        }
    }

    // DELETE /comments/{commentId}
    public void delete(long commentId, long loginUid) {
        int ok = postCommentMapper.softDeleteByOwner(commentId, loginUid);
        if (ok != 1) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "NOT_OWNER_OR_NOT_ACTIVE");
        }
    }
}

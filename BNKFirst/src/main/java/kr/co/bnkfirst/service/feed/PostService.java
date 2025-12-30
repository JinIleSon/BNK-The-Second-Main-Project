package kr.co.bnkfirst.service.feed;

import kr.co.bnkfirst.dto.feed.PostDTO;
import kr.co.bnkfirst.dto.feed.PostListResponse;
import kr.co.bnkfirst.mapper.feed.PostMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/*
    날짜 : 2025.12.24
    이름 : 이준우
    내용 : 게시글 비즈니스 로직(목록/상세/작성/수정/삭제 + 좋아요/댓글)
 */

@Service
public class PostService {

    private final PostMapper postMapper;

    public PostService(PostMapper postMapper) {
        this.postMapper = postMapper;
    }

    // 커뮤니티(BOARD) 목록
    @Transactional(readOnly = true)
    public PostListResponse listBoard(Long lastPostId, int size) {
        return listByType("BOARD", lastPostId, size);
    }

    // 타입별 목록(BOARD/FEED 확장)
    @Transactional(readOnly = true)
    public PostListResponse listByType(String postType, Long lastPostId, int size) {
        int pageSize = Math.min(Math.max(size, 1), 50);

        List<PostDTO> items = postMapper.selectPostList(postType, lastPostId, pageSize);

        boolean hasNext = items.size() == pageSize;
        Long nextLastPostId = items.isEmpty() ? null : items.get(items.size() - 1).getPostid();

        return PostListResponse.builder()
                .items(items)
                .nextLastPostId(nextLastPostId)
                .hasNext(hasNext)
                .build();
    }

    // 커뮤니티(BOARD) 상세
    @Transactional
    public PostDTO detailBoard(Long postId, boolean increaseView) {
        return detailByType("BOARD", postId, increaseView);
    }

    // 타입별 상세
    @Transactional
    public PostDTO detailByType(String postType, Long postId, boolean increaseView) {
        if (increaseView) {
            postMapper.increaseViewCount(postId);
        }

        PostDTO dto = postMapper.selectPostDetail(postId, postType);
        if (dto == null) {
            throw new IllegalArgumentException("게시글이 없거나 삭제되었습니다. postId=" + postId);
        }
        return dto;
    }

    // 커뮤니티(BOARD) 작성
    @Transactional
    public Long createBoard(PostDTO req, Long authorUid) {
        if (authorUid == null) throw new IllegalStateException("로그인이 필요합니다.");
        if (req == null || req.getBody() == null || req.getBody().isBlank()) {
            throw new IllegalArgumentException("본문(body)은 필수입니다.");
        }

        PostDTO dto = PostDTO.builder()
                .authoruId(authorUid)
                .posttype("BOARD")
                .title(trimOrNull(req.getTitle()))
                .body(req.getBody())
                .coverurl(trimOrNull(req.getCoverurl()))
                .market(null)
                .build();

        int ok = postMapper.insertPost(dto);
        if (ok != 1) throw new IllegalStateException("게시글 생성 실패");

        return postMapper.selectPostCurrval();
    }

    // 커뮤니티(BOARD) 수정
    @Transactional
    public void updateBoard(Long postid, PostDTO req, Long authoruId) {
        if (authoruId == null) throw new IllegalStateException("로그인이 필요합니다.");
        if (req == null || req.getBody() == null || req.getBody().isBlank()) {
            throw new IllegalArgumentException("본문(body)은 필수입니다.");
        }

        PostDTO dto = PostDTO.builder()
                .postid(postid)
                .authoruId(authoruId)
                .posttype("BOARD")
                .title(trimOrNull(req.getTitle()))
                .body(req.getBody())
                .coverurl(trimOrNull(req.getCoverurl()))
                .build();

        int ok = postMapper.updatePost(dto);
        if (ok != 1) {
            throw new IllegalStateException("수정 실패(권한 없음/글 없음). postId=" + postid);
        }
    }

    // 커뮤니티(BOARD)
    @Transactional
    public void deleteBoard(Long postId, Long authorUid) {
        if (authorUid == null) throw new IllegalStateException("로그인이 필요합니다.");

        int ok = postMapper.softDeletePost(postId, authorUid, "BOARD");
        if (ok != 1) {
            throw new IllegalStateException("삭제 실패(권한 없음/글 없음). postId=" + postId);
        }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isBlank() ? null : t;
    }
}
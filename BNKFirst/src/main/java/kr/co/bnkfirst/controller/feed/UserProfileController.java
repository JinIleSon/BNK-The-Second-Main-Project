package kr.co.bnkfirst.controller.feed;

import kr.co.bnkfirst.security.LoginUidProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import kr.co.bnkfirst.dto.feed.*;
import kr.co.bnkfirst.service.feed.UserProfileService;

import java.util.List;

/*
    날짜 : 2025.12.24, 01.03
    이름 : 이준우
    내용 : 유저프로필
 */

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/profile")
public class UserProfileController {

    private final UserProfileService userProfileService;
    private final LoginUidProvider loginUidProvider;

    @GetMapping("/me")
    public ResponseEntity<UserProfileViewDTO> me() {
        Long uId = loginUidProvider.requireUid();
        userProfileService.ensureProfileRow(uId);
        return ResponseEntity.ok(userProfileService.getMyProfileView(uId));
    }

    @PutMapping("/me")
    public ResponseEntity<UserProfileDTO> updateMe(@RequestBody UpdateReq req) {
        Long uId = loginUidProvider.requireUid();
        return ResponseEntity.ok(
                userProfileService.updateMyProfile(uId, req.nickname, req.avatarUrl, req.bio)
        );
    }

    @GetMapping("/me/posts")
    public ResponseEntity<List<MyPostItemDTO>> myPosts(
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Long lastPostId
    ) {
        Long uId = loginUidProvider.requireUid();
        return ResponseEntity.ok(userProfileService.getMyPosts(uId, size, lastPostId));
    }

    @GetMapping("/me/comments")
    public ResponseEntity<List<MyCommentItemDTO>> myComments(
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Long lastCommentId
    ) {
        Long uId = loginUidProvider.requireUid();
        return ResponseEntity.ok(userProfileService.getMyComments(uId, size, lastCommentId));
    }

    @GetMapping("/me/likes")
    public ResponseEntity<List<MyLikeItemDTO>> myLikes(
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Long lastLikeId
    ) {
        Long uId = loginUidProvider.requireUid();
        return ResponseEntity.ok(userProfileService.getMyLikedPosts(uId, size, lastLikeId));
    }

    public static class UpdateReq {
        public String nickname;
        public String avatarUrl;
        public String bio;
    }
}
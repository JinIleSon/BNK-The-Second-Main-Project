package kr.co.bnkfirst.service.feed;

import java.util.List;

import kr.co.bnkfirst.mapper.feed.PostLikeMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.co.bnkfirst.dto.feed.*;
import kr.co.bnkfirst.mapper.feed.UserProfileMapper;

/*
    날짜 : 2025.12.24
    이름 : 이준우
    내용 : 사용자 프로필 비즈니스 로직(조회/등록/수정/삭제)
 */

@Service
public class UserProfileService {

    private final UserProfileMapper userProfileMapper;
    private final PostLikeMapper postLikeMapper;

    public UserProfileService(UserProfileMapper userProfileMapper, PostLikeMapper postLikeMapper) {
        this.userProfileMapper = userProfileMapper;
        this.postLikeMapper = postLikeMapper;
    }

    // 없으면 기본 row 생성
    @Transactional
    public void ensureProfileRow(Long uId) {
        UserProfileDTO exist = userProfileMapper.selectByUid(uId);
        if (exist == null) {
            userProfileMapper.insertDefault(uId);
        }
    }

    @Transactional(readOnly = true)
    public UserProfileViewDTO getMyProfileView(Long uId) {
        UserProfileDTO profile = userProfileMapper.selectByUid(uId);

        UserProfileViewDTO view = new UserProfileViewDTO();
        view.setProfile(profile);
        view.setPostCount(userProfileMapper.countMyPosts(uId));
        view.setCommentCount(userProfileMapper.countMyComments(uId));
        view.setLikeCount(userProfileMapper.countMyLikes(uId));
        view.setLikeCount(postLikeMapper.countByUserId(uId));

        return view;
    }

    @Transactional
    public UserProfileDTO updateMyProfile(Long uId, String nickname, String avatarUrl, String bio) {
        ensureProfileRow(uId);

        UserProfileDTO current = userProfileMapper.selectByUid(uId);
        if (current == null) throw new IllegalStateException("프로필 row 생성 실패");
        if (nickname != null) current.setNickname(nickname);
        if (avatarUrl != null) current.setAvatarUrl(avatarUrl);
        if (bio != null) current.setBio(bio);

        userProfileMapper.updateProfile(current);
        return userProfileMapper.selectByUid(uId);
    }

    @Transactional(readOnly = true)
    public List<MyPostItemDTO> getMyPosts(Long uId, int size, Long lastPostId) {
        return userProfileMapper.selectMyPosts(uId, size, lastPostId);
    }

    @Transactional(readOnly = true)
    public List<MyCommentItemDTO> getMyComments(Long uId, int size, Long lastCommentId) {
        return userProfileMapper.selectMyComments(uId, size, lastCommentId);
    }

    @Transactional(readOnly = true)
    public List<MyLikeItemDTO> getMyLikedPosts(Long uId, int size, Long lastLikeId) {
        return userProfileMapper.selectMyLikedPosts(uId, size, lastLikeId);
    }
}
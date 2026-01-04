package kr.co.bnkfirst.dto.feed;

public class ToggleLikeResult {
    private boolean liked;
    private long likeCount;

    public ToggleLikeResult(boolean liked, long likeCount) {
        this.liked = liked;
        this.likeCount = likeCount;
    }

    public boolean getLiked() { return liked; }
    public long getLikeCount() { return likeCount; }
    public boolean isLiked() { return liked; }
}
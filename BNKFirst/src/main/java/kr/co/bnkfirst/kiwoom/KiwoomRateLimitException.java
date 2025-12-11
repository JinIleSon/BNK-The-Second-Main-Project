package kr.co.bnkfirst.kiwoom;

public class KiwoomRateLimitException extends RuntimeException {
    public KiwoomRateLimitException(String message) {
        super(message);
    }
}

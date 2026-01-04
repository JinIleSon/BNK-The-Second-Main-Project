package kr.co.bnkfirst.controller.feed;

import kr.co.bnkfirst.security.LoginUidProvider;
import kr.co.bnkfirst.service.feed.PostRecommendService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/post")
public class PostRecommendController {
    private final PostRecommendService service;
    private final LoginUidProvider loginUidProvider;

    public PostRecommendController(PostRecommendService service, LoginUidProvider loginUidProvider) {
        this.service = service;
        this.loginUidProvider = loginUidProvider;
    }

    @GetMapping("/recommend")
    public Object recommend(@RequestParam(defaultValue = "20") int size) {
        Long uId = loginUidProvider.optionalUidOrNull();
        return service.recommend(uId, Math.min(size, 50));
    }
}
package kr.co.bnkfirst.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class GuideController {

    @GetMapping("/info/guide/ceoGreeting")
    public String ceoGreeting(){
        return "info/guide/ceoGreeting/info_ceoGreeting";
    }

    @GetMapping("/info/guide/coreValues")
    public String coreValue() {
        return "info/guide/coreValues/info_coreValues";
    }

    @GetMapping("/info/guide/groupMission")
    public String groupMission() {
        return "info/guide/groupMission/info_groupMission";
    }

    @GetMapping("/info/guide/groupVision")
    public String groupVision() {
        return "info/guide/groupVision/info_groupVision";
    }

    @GetMapping("/info/guide/missionStrategy")
    public String missionStrategy() {
        return "info/guide/missionStrategy/info_missionStrategy";
    }

    @GetMapping("/info/guide/strategySlogan")
    public String strategySlogan() {
        return "info/guide/strategySlogan/info_strategySlogan";
    }

    @GetMapping("/info/guide")
    public String guideIndex() {
        return "info/index";
    }

    @GetMapping("/info/story")
    public String storyIndex() {return  "info/story/info_story";}

    @GetMapping("/board/press")
    public String pressIndex() {return  "info/board/storyPress/list";}

    @GetMapping("/board/notice")
    public String NoticeIndex() {return  "info/board/storyNotice/list";}

    @GetMapping("/board/event")
    public String eventIndex() {return  "info/board/storyEvent/list";}

    @GetMapping("/board/news")
    public String newsIndex() {return  "info/board/storyNews/list";}

    @GetMapping("/board/media")
    public String mediaIndex() {return  "info/board/storyMedia/list";}

    @GetMapping("/info/invest")
    public String investIndex() {return  "info/invest/info_invest";}

    @GetMapping("/info/branch")
    public String branchIndex() {return  "info/branch/info_branch";}
}

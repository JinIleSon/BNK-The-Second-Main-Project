package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.Info.EventDTO;
import kr.co.bnkfirst.dto.Info.PageRequestDTO;
import kr.co.bnkfirst.dto.Info.PageResponseDTO;
import kr.co.bnkfirst.service.EventService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Slf4j
@Controller
@RequiredArgsConstructor
@RequestMapping("/info/board")   // ✅ 여기 /BNK 제거했지?
public class InfoBoardController {

    private final EventService eventService;

    /** 투자자정보 */
    @GetMapping("/info/invest")
    public String invest() {
        return "info/invest/info_invest";
    }


    /** ✅ 임시 테스트용 */
    @GetMapping("/check")
    @ResponseBody
    public String check() {
        return "InfoBoardController loaded OK";
    }

    @GetMapping("/storyEvent/list")
    public String eventList(PageRequestDTO pageRequestDTO, Model model) {
        PageResponseDTO<EventDTO> pageResponseDTO = eventService.getEventList(pageRequestDTO);

        // ✅ HTML에서 사용하는 변수명에 맞게 모델 속성 추가
        model.addAttribute("boardName", "이벤트");
        model.addAttribute("boardDescription", "부산은행의 다양한 이벤트를 만나보세요.");
        model.addAttribute("articles", pageResponseDTO.getDtoList());
        model.addAttribute("totalCount", pageResponseDTO.getTotal());
        model.addAttribute("totalPage", pageResponseDTO.getTotalPage());

        log.info("이벤트 목록 조회 완료: {}", pageResponseDTO.getDtoList().size());
        return "info/board/storyEvent/list";

    }


    /** ✅ 이벤트 상세 페이지 */
    @GetMapping("/storyEvent/view")
    public String eventView(@RequestParam("eventId") int eventId, Model model) {
        EventDTO eventDTO = eventService.getEvent(eventId);
        if (eventDTO == null) {
            log.warn("eventId={} 데이터 없음 → 목록으로 리다이렉트", eventId);
            return "redirect:info/board/storyEvent/list";
        }
        model.addAttribute("eventDTO", eventDTO);
        log.info("이벤트 상세 페이지 이동: {}", eventDTO.getTitle());
        return "info/board/storyEvent/view";
    }
}

package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.Info.EventDTO;
import kr.co.bnkfirst.dto.Info.PageRequestDTO;
import kr.co.bnkfirst.dto.Info.PageResponseDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class EventServiceImpl implements EventService {

    // 나중에 Mapper나 Repository를 주입하면 됩니다.
    // private final EventMapper eventMapper;

    @Override
    public PageResponseDTO<EventDTO> getEventList(PageRequestDTO pageRequestDTO) {
        log.info("이벤트 목록 요청: {}", pageRequestDTO);

        // 현재는 임시 데이터 (DB 연동 전용)
        EventDTO sample = new EventDTO();
        sample.setEventId(1);
        sample.setTitle("샘플 이벤트");
        sample.setContent("이벤트 내용입니다.");
        sample.setThumbnail("");

        List<EventDTO> list = List.of(sample);
        int total = 1;

        // ✅ builder() 제거 → 생성자 호출로 변경
        return new PageResponseDTO<>(pageRequestDTO, total, list);
    }

    @Override
    public EventDTO getEvent(int eventId) {
        log.info("이벤트 상세 조회: {}", eventId);

        // DB 연동 전용
        EventDTO event = new EventDTO();
        event.setEventId(eventId);
        event.setTitle("샘플 이벤트 상세");
        event.setContent("상세 내용입니다.");
        event.setThumbnail("");


        return event;
    }
}

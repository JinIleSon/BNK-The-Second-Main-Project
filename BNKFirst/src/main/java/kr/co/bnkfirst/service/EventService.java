package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.Info.EventDTO;
import kr.co.bnkfirst.dto.Info.PageRequestDTO;
import kr.co.bnkfirst.dto.Info.PageResponseDTO;


public interface EventService {

    /** ✅ 이벤트 목록 조회 */
    PageResponseDTO<EventDTO> getEventList(PageRequestDTO pageRequestDTO);

    /** ✅ 이벤트 단건 조회 */
    EventDTO getEvent(int eventId);
}

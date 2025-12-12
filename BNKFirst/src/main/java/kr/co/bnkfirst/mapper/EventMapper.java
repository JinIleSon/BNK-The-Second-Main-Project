package kr.co.bnkfirst.mapper;

import kr.co.bnkfirst.dto.Info.EventDTO;
import kr.co.bnkfirst.dto.Info.PageRequestDTO;  // ✅ info 폴더 안에 있으므로 이렇게 수정
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface EventMapper {

    /** 이벤트 목록 조회 (페이징 지원) */
    @Select("""
        SELECT event_id AS eventId,
               title,
               content,
               start_date AS startDate,
               end_date AS endDate,
               status
        FROM tbEvent
        ORDER BY event_id DESC
        OFFSET #{offset} ROWS FETCH NEXT #{size} ROWS ONLY
    """)
    List<EventDTO> selectEventList(PageRequestDTO pageRequestDTO);

    /** 총 이벤트 개수 */
    @Select("SELECT COUNT(*) FROM tbEvent")
    int countEvents(PageRequestDTO pageRequestDTO);

    /** 이벤트 상세조회 */
    @Select("""
        SELECT event_id AS eventId,
               title,
               content,
               start_date AS startDate,
               end_date AS endDate,
               status
        FROM tbEvent
        WHERE event_id = #{eventId}
    """)
    EventDTO selectEventById(@Param("eventId") int eventId);

    /** 이벤트 등록 */
    @Insert("""
        INSERT INTO tbEvent (event_id, title, content, start_date, end_date, status)
        VALUES (tbEvent_seq.NEXTVAL, #{title}, #{content}, #{startDate}, #{endDate}, #{status})
    """)
    void insertEvent(EventDTO eventDTO);

    /** 이벤트 수정 */
    @Update("""
        UPDATE tbEvent
        SET title = #{title},
            content = #{content},
            start_date = #{startDate},
            end_date = #{endDate},
            status = #{status}
        WHERE event_id = #{eventId}
    """)
    void updateEvent(EventDTO eventDTO);

    /** 이벤트 삭제 */
    @Delete("DELETE FROM tbEvent WHERE event_id = #{eventId}")
    void deleteEvent(@Param("eventId") int eventId);
}

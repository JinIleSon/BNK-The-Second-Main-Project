package kr.co.bnkfirst.kiwoom;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class HistoricalCandle {
    private LocalDateTime dateTime; // 2024-11-18T10:01
    private long open;
    private long high;
    private long low;
    private long close;
}

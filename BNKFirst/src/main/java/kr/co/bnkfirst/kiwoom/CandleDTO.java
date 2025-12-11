// src/main/java/kr/co/bnkfirst/kiwoom/CandleDto.java
package kr.co.bnkfirst.kiwoom;

public class CandleDTO {

    // LightweightCharts 에 바로 넣기 좋은 unix seconds
    private long time;   // 예: 1731906000
    private long open;
    private long high;
    private long low;
    private long close;

    public CandleDTO(long time, long open, long high, long low, long close) {
        this.time = time;
        this.open = open;
        this.high = high;
        this.low = low;
        this.close = close;
    }

    public long getTime()  { return time; }
    public long getOpen()  { return open; }
    public long getHigh()  { return high; }
    public long getLow()   { return low; }
    public long getClose() { return close; }

    public void setTime(long time)     { this.time = time; }
    public void setOpen(long open)     { this.open = open; }
    public void setHigh(long high)     { this.high = high; }
    public void setLow(long low)       { this.low = low; }
    public void setClose(long close)   { this.close = close; }
}

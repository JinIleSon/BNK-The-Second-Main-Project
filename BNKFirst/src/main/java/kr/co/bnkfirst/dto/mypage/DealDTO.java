package kr.co.bnkfirst.dto.mypage;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DealDTO {

    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int did;
    private String mid;
    private int dbalance;
    private String dwho;
    @CreationTimestamp
    private LocalDateTime ddate;
}

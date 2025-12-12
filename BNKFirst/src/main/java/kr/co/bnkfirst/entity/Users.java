package kr.co.bnkfirst.entity;

import jakarta.persistence.*;
import kr.co.bnkfirst.dto.UsersDTO;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "USERS")
public class Users {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"uId\"")
    private int uid;
    private String mid;
    private String mpw;
    private String mname;
    private LocalDate mbirth;
    private String mgender;
    private String mcarrier;
    private String memail;
    private String mphone;
    private String maddress;
    @CreationTimestamp
    private LocalDateTime mdate;
    private String mgrade;
    private String mjumin;
    private String mcond;
    private String mnum;
    @CreationTimestamp
    private LocalDateTime maccess;
    private String mlimit;


    private String mci;

    private String role;

    public UsersDTO toDTO(){
        return UsersDTO.builder()
                .uid(uid)
                .mid(mid)
                .mpw(mpw)
                .mname(mname)
                .mbirth(mbirth)
                .mgender(mgender)
                .mcarrier(mcarrier)
                .memail(memail)
                .mphone(mphone)
                .maddress(maddress)
                .mdate(mdate)
                .mgrade(mgrade)
                .mjumin(mjumin)
                .mcond(mcond)
                .mnum(mnum)
                .maccess(maccess)
                .mlimit(mlimit)
                .mci(mci)
                .role(role)
                .build();
    }
}
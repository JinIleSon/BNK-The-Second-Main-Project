package kr.co.bnkfirst.dto.admin;

import kr.co.bnkfirst.dto.product.ProductDTO;
import kr.co.bnkfirst.dto.product.FundDTO;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AdminProductRowDTO {

    /** 어떤 종류인지 구분 (예금/적금 vs 펀드) */
    private String kind;          // "PRODUCT" / "FUND"

    /** 공통 컬럼 (테이블 헤더 기준) */
    private String productId;     // 상품ID  : product.pid / fund.fid
    private String name;          // 상품명  : pname / fname
    private String rateOrFee;     // 최고금리 / 총보수 : phirate / ftc
    private String periodOrRisk;  // 기간 / 위험등급  : prmthd / frlvl
    private String statusOrType;  // 유형     : pcond / ftype
    private String regOrSetDate;  // 등록일 / 설정일 : pupdate / fsetdt (yyyy-MM-dd 형태 권장)

    /** 관리 버튼용 URL */
    private String modifyUrl;     // /admin/prod/modify?pid=...  or /admin/fund/modify?fid=...
    private String deleteUrl;     // /admin/prod/delete?pid=... or /admin/fund/delete?fid=...

    /* ================== 매핑 메서드 (Product → Row) ================== */

    public static AdminProductRowDTO from(ProductDTO p) {

        // pupdate: "2025-11-10 00:00:00" 형식일 수도 있으니 앞 10자리만 사용
        String date = p.getPupdate();
        if (date != null && date.length() >= 10) {
            date = date.substring(0, 10);
        }

        // 최고금리: 소수점 2자리 + % 표시 (원하는대로 포맷 수정 가능)
        String hiRateStr = String.format("%.2f", p.getPbirate());

        return AdminProductRowDTO.builder()
                .kind("PRODUCT")
                .productId(p.getPid())
                .name(p.getPname())
                .rateOrFee(hiRateStr)
                .periodOrRisk(p.getPrmthd())       // "3~36개월" 같은 문자열 그대로 사용
                .statusOrType(p.getPelgbl())       // DC, DB, IRP인지
                .regOrSetDate(date)
                .modifyUrl("/BNK/admin/prod/modify?pid=" + p.getPid())
                .deleteUrl("/BNK/admin/prod/delete?pid=" + p.getPid())
                .build();
    }

    /* ================== 매핑 메서드 (Fund → Row) ================== */

    public static AdminProductRowDTO from(FundDTO f) {

        String date = f.getFsetdt();
        if (date != null && date.length() >= 10) {
            date = date.substring(0, 10);
        }

        // 총보수: 소수점 4자리 + % (스펙에 맞춰서)
        String tcStr = String.format("%.4f", f.getFtc());

        // 위험등급: 1~6 숫자 → "위험 3등급" 같은 표현으로
        String risk = f.getFrlvl() > 0
                ? "위험 " + f.getFrlvl() + "등급"
                : "-";

        return AdminProductRowDTO.builder()
                .kind("FUND")
                .productId(f.getFid())
                .name(f.getFname())
                .rateOrFee(tcStr)
                .periodOrRisk(risk)
                .statusOrType(f.getFtype())       // "채권형 / 주식형 / MMF / ..." 등
                .regOrSetDate(date)
                .modifyUrl("/BNK/admin/fund/modify?fid=" + f.getFid())
                .deleteUrl("/BNK/admin/fund/delete?fid=" + f.getFid())
                .build();
    }
}

package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.DocumentDTO;
import kr.co.bnkfirst.dto.MainEventDTO;
import kr.co.bnkfirst.dto.PageRequestDTO;
import kr.co.bnkfirst.dto.admin.PageResponseAdminDocumentDTO;
import kr.co.bnkfirst.mapper.DocumentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DocumentService {
    private final DocumentMapper documentMapper;

    public List<DocumentDTO> getAllDocuments(String type) {
        return documentMapper.selectAllDocumentsByType(type);
    }

    public void insertDocument(DocumentDTO dto){
        documentMapper.insertDocument(dto);
    }

    public List<DocumentDTO> searchDocuments(String keyword) {
        return documentMapper.searchDocuments(keyword);
    }

    public List<DocumentDTO> getLatestDocuments2() {
        return documentMapper.selectLatestDocuments2();
    }

    // 메인페이지 이벤트용
    public List<MainEventDTO> getMainEvents() {
        return documentMapper.selectMainEvents();
    }


    // ====== 여기부터 관리자용(admin_cs) ======

    // admin 전체 리스트 (페이징 없음, JS에서 처리)
    public List<DocumentDTO> getAdminDocuments(String doctype) {
        return documentMapper.selectAdminDocumentsAll(doctype);
    }


    // 목록 + 페이지네이션
    public PageResponseAdminDocumentDTO getAdminDocumentPage(
            String group,
            String type,
            PageRequestDTO pageRequestDTO
    ) {
        // group+type → DOCTYPE 값 매핑
        String doctype = resolveDoctype(group, type);

        // 혹시라도 매핑 안 된 조합이면 바로 예외 내보내기 (디버깅용)
        if (doctype == null) {
            throw new IllegalArgumentException("지원하지 않는 group/type: " + group + "/" + type);
        }

        List<DocumentDTO> list =
                documentMapper.selectAdminDocuments(doctype, pageRequestDTO);
        int total =
                documentMapper.countAdminDocuments(doctype, pageRequestDTO);

        return PageResponseAdminDocumentDTO.builder()
                .pageRequestDTO(pageRequestDTO)
                .dtoList(list)
                .total(total)
                .build();
    }


    /**
     * admin 화면의 group/type 값을 DB DOCTYPE 문자열로 매핑
     */
    public String resolveDoctype(String group, String type) {

        return switch (group) {
            // ----------------- 고객센터 -----------------
            case "cs" -> switch (type) {
                case "faq"  -> "FAQ";          // ★ 여기
                case "doc"  -> "필요서류";     // ★ 여기
                case "qna"  -> "Q&A";          // ★ 여기
                default     -> null;
            };

            // ----------------- 퇴직연금서식 -----------------
            case "form" -> switch (type) {
                case "db"   -> "DB(확정급여형)";   // ★
                case "dc"   -> "DC(확정기여형)";   // ★
                case "pirp" -> "개인형IRP";        // ★
                case "cirp" -> "기업형IRP";        // ★
                default     -> null;
            };

            // ----------------- 퇴직연금자료 -----------------
            case "data" -> switch (type) {
                case "room"      -> "자료실";          // ★
                case "smallfund" -> "소규모펀드등공시"; // ★
                case "notice"    -> "공지사항";        // ★
                case "contract"  -> "퇴직연금계약서";  // ★
                default          -> null;
            };

            default -> null;
        };
    }

    // 단건 조회
    public DocumentDTO getDocumentById(int docid) {
        return documentMapper.selectAdminDocumentById(docid);
    }

    // 관리자 등록
    public void insertAdminDocument(DocumentDTO dto) {
        documentMapper.insertAdminDocument(dto);
    }

    // 관리자 수정
    public void updateAdminDocument(DocumentDTO dto) {
        documentMapper.updateAdminDocument(dto);
    }

    // 관리자 삭제
    public void deleteAdminDocument(int docid) {
        documentMapper.deleteAdminDocument(docid);
    }
}

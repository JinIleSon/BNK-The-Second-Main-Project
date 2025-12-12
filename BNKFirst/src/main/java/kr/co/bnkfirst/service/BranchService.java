package kr.co.bnkfirst.service;

import kr.co.bnkfirst.dto.BranchDTO;
import kr.co.bnkfirst.dto.PageRequestDTO;
import kr.co.bnkfirst.mapper.BranchMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BranchService {

    private final BranchMapper branchMapper;

    /** ===== 공통 전처리 ===== */
    private void normalize(BranchDTO dto) {
        if (dto.getBrname() != null) dto.setBrname(dto.getBrname().trim());
        if (dto.getBraddr() != null) dto.setBraddr(dto.getBraddr().trim());
        if (dto.getBrtel() != null) dto.setBrtel(dto.getBrtel().trim());
        if (dto.getBrfax() != null) dto.setBrfax(dto.getBrfax().trim());
        if (dto.getType() != null) dto.setType(dto.getType().trim());
    }

    private void validateRequired(BranchDTO dto) {
        if (dto.getBrname() == null || dto.getBrname().isBlank())
            throw new IllegalArgumentException("지점명(BRNAME)은 필수입니다.");
        if (dto.getBraddr() == null || dto.getBraddr().isBlank())
            throw new IllegalArgumentException("주소(BRADDR)는 필수입니다.");
        if (dto.getBrtel() == null || dto.getBrtel().isBlank())
            throw new IllegalArgumentException("전화번호(BRTEL)는 필수입니다.");
        if (dto.getType() == null || dto.getType().isBlank())
            throw new IllegalArgumentException("지점 분류(TYPE)는 필수입니다.");
    }

    /** 전체 조회 */
    public List<BranchDTO> getAllBranches() {
        return branchMapper.findAllBranches();
    }

    /** 페이징 */
    public List<BranchDTO> getBranchPage(PageRequestDTO pageRequestDTO) {
        return branchMapper.findBranchPage(pageRequestDTO.getOffset(), pageRequestDTO.getSize());
    }

    /** 총 개수 */
    public int getBranchTotal() {
        return branchMapper.countBranches();
    }

    /** 검색 */
    public List<BranchDTO> searchBranches(String keyword) {
        String word = (keyword == null ? "" : keyword.trim());
        if (word.isEmpty()) return branchMapper.findAllBranches();
        return branchMapper.searchBranches(word);
    }

    /** 등록 */
    public void insertBranch(BranchDTO dto) {
        validateRequired(dto);
        normalize(dto);
        branchMapper.insertBranch(dto);
    }

    /** 단일 조회 */
    public BranchDTO getBranchById(int brid) {
        return branchMapper.findBranchById(brid);
    }

    /** 수정 */
    public void updateBranch(BranchDTO dto) {
        validateRequired(dto);
        normalize(dto);
        branchMapper.updateBranch(dto);
    }

    /** 삭제 */
    public void deleteBranch(int brid) {
        BranchDTO exist = branchMapper.findBranchById(brid);
        if (exist == null) {
            throw new IllegalArgumentException("존재하지 않는 지점입니다. BRID=" + brid);
        }
        branchMapper.deleteBranch(brid);
    }
}

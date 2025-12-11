package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.BranchDTO;
import kr.co.bnkfirst.service.BranchService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/branch")
@RequiredArgsConstructor
public class CsBranchController {

    private final BranchService branchService;

    // 전체 조회
    @GetMapping
    public List<BranchDTO> getAllBranches() {
        log.info("[GET] 전체 지점 목록 요청");
        return branchService.getAllBranches();
    }

    // 검색
    @GetMapping("/search")
    public List<BranchDTO> searchBranches(@RequestParam(required = false) String keyword) {
        log.info("[GET] 지점 검색 요청 keyword={}", keyword);
        return branchService.searchBranches(keyword);
    }
}
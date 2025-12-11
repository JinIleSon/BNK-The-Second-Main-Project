package kr.co.bnkfirst.controller;

import kr.co.bnkfirst.dto.admin.SvgUploadResultDTO;
import kr.co.bnkfirst.service.SvgUploadResultService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@Slf4j
@RequiredArgsConstructor
public class SvgUploadResultController {

    private final SvgUploadResultService svgUploadResultService;

    @PostMapping(value="/tologo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public SvgUploadResultDTO upload(@RequestParam("file") MultipartFile file){
        try {
            long version = svgUploadResultService.saveAsSvg(file);
            return new SvgUploadResultDTO(true, null, version);
        } catch (Exception e){
            return new SvgUploadResultDTO(false, e.getMessage(), System.currentTimeMillis());
        }
    }
}

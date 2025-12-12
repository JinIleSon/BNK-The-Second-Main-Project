package kr.co.bnkfirst.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.Base64;

@Service
@Slf4j
@RequiredArgsConstructor
public class SvgUploadResultService {

    private final String uploadDir = "upload";

    public long saveAsSvg(MultipartFile file) throws IOException {
        if (file.isEmpty()) throw new IllegalArgumentException("빈 파일입니다.");
        String mime = file.getContentType();
        if (mime == null || !mime.startsWith("image/"))
            throw new IllegalArgumentException("이미지 파일만 업로드할 수 있습니다.");

        // 저장 폴더: {uploadDir}/images
        Path dir = Paths.get(uploadDir, "images");
        Files.createDirectories(dir);
        Path target = dir.resolve("bnk_logo.svg");

        byte[] bytes = file.getBytes();
        String content;
        String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename().toLowerCase() : "";
        if ("image/svg+xml".equalsIgnoreCase(mime) || originalName.endsWith(".svg")) {
            content = new String(bytes, StandardCharsets.UTF_8);
        } else {
            String b64 = Base64.getEncoder().encodeToString(bytes);
            content = """
                <svg xmlns="http://www.w3.org/2000/svg" width="200" height="80">
                  <image href="data:%s;base64,%s" width="100%%" height="100%%" preserveAspectRatio="xMidYMid meet"/>
                </svg>
                """.formatted(mime, b64);
        }

        Files.writeString(target, content, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        return System.currentTimeMillis();
    }
}

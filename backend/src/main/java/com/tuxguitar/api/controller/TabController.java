package com.tuxguitar.api.controller;

import com.tuxguitar.api.model.SongResponse;
import com.tuxguitar.api.service.TabParserService;
import com.tuxguitar.api.service.AudioService;
import app.tuxguitar.io.base.TGFileFormatException;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("/api/tabs")
@CrossOrigin(origins = "*")
public class TabController {

    private final TabParserService parserService;
    private final AudioService audioService;

    public TabController(TabParserService parserService, AudioService audioService) {
        this.parserService = parserService;
        this.audioService = audioService;
    }

    @PostMapping("/parse")
    public ResponseEntity<?> parseFile(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "File is empty"));
        }

        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || !isSupportedFormat(originalFilename)) {
            return ResponseEntity.badRequest().body(Map.of("error", "Unsupported file format. Supported: .gp3, .gp4, .gp5, .gpx, .gp, .xml, .midi, .mid"));
        }

        try {
            SongResponse songResponse = parserService.parseSong(file.getInputStream());
            return ResponseEntity.ok(songResponse);
        } catch (TGFileFormatException e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Failed to parse file: " + e.getMessage()));
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "Failed to read file: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "Internal error: " + e.getMessage()));
        }
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "ok", "service", "tuxguitar-api"));
    }

    @PostMapping("/render-audio")
    public ResponseEntity<?> renderAudio(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "File is empty"));
        }

        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || !isSupportedFormat(originalFilename)) {
            return ResponseEntity.badRequest().body(Map.of("error", "Unsupported file format"));
        }

        try {
            byte[] wavData = audioService.renderToWav(file.getInputStream());
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("audio/wav"));
            headers.setContentDispositionFormData("attachment", "tab_audio.wav");
            return ResponseEntity.ok().headers(headers).body(wavData);
        } catch (TGFileFormatException e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Failed to parse file: " + e.getMessage()));
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "Failed to render audio: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "Internal error: " + e.getMessage()));
        }
    }

    private boolean isSupportedFormat(String filename) {
        String lower = filename.toLowerCase();
        return lower.endsWith(".gp3") ||
               lower.endsWith(".gp4") ||
               lower.endsWith(".gp5") ||
               lower.endsWith(".gpx") ||
               lower.endsWith(".gp") ||
               lower.endsWith(".xml") ||
               lower.endsWith(".midi") ||
               lower.endsWith(".mid");
    }
}

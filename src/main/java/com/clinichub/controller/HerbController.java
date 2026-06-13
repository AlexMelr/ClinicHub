package com.clinichub.controller;

import com.clinichub.entity.Herb;
import com.clinichub.repository.HerbRepository;
import com.clinichub.service.HerbService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/herbs")
@RequiredArgsConstructor
public class HerbController {
    private final HerbService herbService;
    private final HerbRepository herbRepository;

    @GetMapping
    public List<Herb> list(@RequestParam(required = false) String keyword,
                           @RequestParam(required = false, defaultValue = "false") boolean lowStock) {
        if (lowStock) return herbService.lowStock();
        if (keyword != null && !keyword.isEmpty()) return herbService.search(keyword);
        return herbService.findAll();
    }

    @GetMapping("/{id}")
    public Herb get(@PathVariable Long id) {
        return herbRepository.findById(id).orElseThrow();
    }

    @PostMapping
    public Herb create(@RequestBody Herb herb) {
        return herbService.create(herb);
    }

    @PutMapping("/{id}")
    public Herb update(@PathVariable Long id, @RequestBody Herb herb) {
        return herbService.update(id, herb);
    }

    @DeleteMapping("/{id}")
    public Map<String, String> delete(@PathVariable Long id) {
        herbService.delete(id);
        return Map.of("message", "ok");
    }
}

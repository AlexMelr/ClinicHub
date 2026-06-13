package com.clinichub.controller;

import com.clinichub.entity.Visit;
import com.clinichub.repository.VisitRepository;
import com.clinichub.service.VisitService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/visits")
@RequiredArgsConstructor
public class VisitController {
    private final VisitService visitService;
    private final VisitRepository visitRepository;

    @GetMapping
    public List<Visit> list(@RequestParam(required = false) Long patientId) {
        if (patientId != null) return visitService.findByPatient(patientId);
        return visitService.findAll();
    }

    @GetMapping("/{id}")
    public Visit get(@PathVariable Long id) {
        return visitRepository.findById(id).orElseThrow();
    }

    @PostMapping
    public Visit create(@RequestBody Visit visit) {
        return visitService.create(visit);
    }

    @PutMapping("/{id}")
    public Visit update(@PathVariable Long id, @RequestBody Visit visit) {
        return visitService.update(id, visit);
    }
}

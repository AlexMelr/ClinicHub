package com.clinichub.controller;

import com.clinichub.entity.Patient;
import com.clinichub.repository.PatientRepository;
import com.clinichub.service.PatientService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/patients")
@RequiredArgsConstructor
public class PatientController {
    private final PatientService patientService;
    private final PatientRepository patientRepository;

    @GetMapping
    public List<Patient> list(@RequestParam(required = false) String keyword) {
        if (keyword != null && !keyword.isEmpty()) return patientService.search(keyword);
        return patientService.findAll();
    }

    @GetMapping("/{id}")
    public Patient get(@PathVariable Long id) {
        return patientRepository.findById(id).orElseThrow();
    }

    @PostMapping
    public Patient create(@RequestBody Patient patient) {
        return patientService.create(patient);
    }

    @PutMapping("/{id}")
    public Patient update(@PathVariable Long id, @RequestBody Patient patient) {
        return patientService.update(id, patient);
    }

    @DeleteMapping("/{id}")
    public Map<String, String> delete(@PathVariable Long id) {
        patientService.delete(id);
        return Map.of("message", "ok");
    }
}

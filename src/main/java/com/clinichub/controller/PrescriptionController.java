package com.clinichub.controller;

import com.clinichub.entity.Prescription;
import com.clinichub.repository.PrescriptionRepository;
import com.clinichub.service.PrescriptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/prescriptions")
@RequiredArgsConstructor
public class PrescriptionController {
    private final PrescriptionService prescriptionService;
    private final PrescriptionRepository prescriptionRepository;

    @GetMapping
    public List<Prescription> list(@RequestParam(required = false) Long visitId) {
        if (visitId != null) return prescriptionService.findByVisit(visitId);
        return prescriptionService.findAll();
    }

    @GetMapping("/{id}")
    public Prescription get(@PathVariable Long id) {
        return prescriptionRepository.findById(id).orElseThrow();
    }

    @PostMapping
    public Prescription create(@RequestBody Prescription prescription) {
        return prescriptionService.create(prescription);
    }

    @PostMapping("/{id}/dispense")
    public Prescription dispense(@PathVariable Long id) {
        return prescriptionService.dispense(id);
    }
}

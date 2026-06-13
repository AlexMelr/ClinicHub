package com.clinichub.service;

import com.clinichub.entity.Patient;
import com.clinichub.repository.PatientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PatientService {
    private final PatientRepository patientRepository;

    public List<Patient> findAll() {
        return patientRepository.findByEnabledTrue();
    }

    public List<Patient> search(String keyword) {
        return patientRepository.findByNameContaining(keyword);
    }

    public Patient create(Patient patient) {
        patient.setCreatedAt(LocalDateTime.now());
        patient.setEnabled(true);
        return patientRepository.save(patient);
    }

    public Patient update(Long id, Patient update) {
        Patient patient = patientRepository.findById(id).orElseThrow();
        if (update.getName() != null) patient.setName(update.getName());
        if (update.getAge() != null) patient.setAge(update.getAge());
        if (update.getGender() != null) patient.setGender(update.getGender());
        if (update.getPhone() != null) patient.setPhone(update.getPhone());
        return patientRepository.save(patient);
    }

    public void delete(Long id) {
        Patient patient = patientRepository.findById(id).orElseThrow();
        patient.setEnabled(false);
        patientRepository.save(patient);
    }
}

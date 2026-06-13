package com.clinichub.service;

import com.clinichub.entity.Patient;
import com.clinichub.entity.Visit;
import com.clinichub.repository.PatientRepository;
import com.clinichub.repository.VisitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class VisitService {
    private final VisitRepository visitRepository;
    private final PatientRepository patientRepository;

    public List<Visit> findAll() {
        return visitRepository.findAllWithPatient();
    }

    public List<Visit> findByPatient(Long patientId) {
        return visitRepository.findByPatientIdOrderByVisitTimeDesc(patientId);
    }

    public Visit create(Visit visit) {
        Patient patient = patientRepository.findById(visit.getPatient().getId()).orElseThrow();
        visit.setPatient(patient);
        visit.setCreatedAt(LocalDateTime.now());
        if (visit.getVisitTime() == null) visit.setVisitTime(LocalDateTime.now());
        return visitRepository.save(visit);
    }

    public Visit update(Long id, Visit update) {
        Visit visit = visitRepository.findById(id).orElseThrow();
        if (update.getVisitTime() != null) visit.setVisitTime(update.getVisitTime());
        if (update.getChiefComplaint() != null) visit.setChiefComplaint(update.getChiefComplaint());
        if (update.getPresentIllness() != null) visit.setPresentIllness(update.getPresentIllness());
        if (update.getPastHistory() != null) visit.setPastHistory(update.getPastHistory());
        if (update.getAllergyHistory() != null) visit.setAllergyHistory(update.getAllergyHistory());
        if (update.getDiagnosis() != null) visit.setDiagnosis(update.getDiagnosis());
        if (update.getAdvice() != null) visit.setAdvice(update.getAdvice());
        if (update.getDoctorNote() != null) visit.setDoctorNote(update.getDoctorNote());
        return visitRepository.save(visit);
    }
}

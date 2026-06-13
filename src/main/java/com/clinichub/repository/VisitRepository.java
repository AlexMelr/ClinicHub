package com.clinichub.repository;

import com.clinichub.entity.Visit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface VisitRepository extends JpaRepository<Visit, Long> {
    List<Visit> findByPatientIdOrderByVisitTimeDesc(Long patientId);
    
    @Query("SELECT v FROM Visit v JOIN FETCH v.patient ORDER BY v.visitTime DESC")
    List<Visit> findAllWithPatient();
}

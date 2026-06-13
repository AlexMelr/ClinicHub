package com.clinichub.repository;

import com.clinichub.entity.Prescription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface PrescriptionRepository extends JpaRepository<Prescription, Long> {
    @Query("SELECT DISTINCT p FROM Prescription p JOIN FETCH p.visit v JOIN FETCH v.patient LEFT JOIN FETCH p.items i LEFT JOIN FETCH i.herb WHERE v.id = :visitId ORDER BY p.createdAt DESC")
    List<Prescription> findByVisitId(@Param("visitId") Long visitId);

    @Query("SELECT DISTINCT p FROM Prescription p JOIN FETCH p.visit v JOIN FETCH v.patient LEFT JOIN FETCH p.items i LEFT JOIN FETCH i.herb WHERE p.id = :id")
    Optional<Prescription> findByIdWithDetails(@Param("id") Long id);
    
    @Query("SELECT DISTINCT p FROM Prescription p JOIN FETCH p.visit v JOIN FETCH v.patient LEFT JOIN FETCH p.items i LEFT JOIN FETCH i.herb ORDER BY p.createdAt DESC")
    List<Prescription> findAllWithDetails();
}

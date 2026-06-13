package com.clinichub.repository;

import com.clinichub.entity.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PatientRepository extends JpaRepository<Patient, Long> {
    List<Patient> findByNameContaining(String name);
    List<Patient> findByPhone(String phone);
    List<Patient> findByEnabledTrue();
}

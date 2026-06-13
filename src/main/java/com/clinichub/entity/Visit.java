package com.clinichub.entity;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "visit")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Visit {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @Column(name = "visit_time", nullable = false)
    private java.time.LocalDateTime visitTime;

    @Column(name = "chief_complaint", length = 255)
    private String chiefComplaint;

    @Column(name = "present_illness", columnDefinition = "tinytext")
    private String presentIllness;

    @Column(name = "past_history", columnDefinition = "tinytext")
    private String pastHistory;

    @Column(name = "allergy_history", columnDefinition = "tinytext")
    private String allergyHistory;

    @Column(columnDefinition = "longtext")
    private String diagnosis;

    @Column(columnDefinition = "longtext")
    private String advice;

    @Column(name = "doctor_note", columnDefinition = "tinytext")
    private String doctorNote;

    @Column(name = "created_at", nullable = false)
    private java.time.LocalDateTime createdAt;
}

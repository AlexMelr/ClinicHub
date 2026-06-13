package com.clinichub.entity;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.List;

@Entity
@Table(name = "prescription")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Prescription {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "visit_id", nullable = false)
    private Visit visit;

    @Column(nullable = false)
    private Integer copies;

    @Column(name = "usage_text", length = 255)
    private String usageText;

    @Column(length = 20, nullable = false)
    private String status;

    @Column(columnDefinition = "longtext")
    private String remark;

    @Column(name = "created_at", nullable = false)
    private java.time.LocalDateTime createdAt;

    @OneToMany(mappedBy = "prescription", fetch = FetchType.LAZY)
    private List<PrescriptionItem> items;
}

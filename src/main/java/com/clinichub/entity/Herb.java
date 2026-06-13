package com.clinichub.entity;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "herb")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Herb {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(name = "alias_name", length = 100)
    private String aliasName;

    @Column(length = 100)
    private String pinyin;

    @Column(name = "stock_g", nullable = false)
    private Integer stockG;

    @Column(length = 10, nullable = false)
    private String unit;

    @Column(name = "warn_threshold_g", nullable = false)
    private Integer warnThresholdG;

    @Column(nullable = false)
    private Boolean enabled = true;

    @Column(name = "created_at", nullable = false)
    private java.time.LocalDateTime createdAt;
}

package com.clinichub.entity;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "stock_flow")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class StockFlow {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "herb_id", nullable = false)
    private Herb herb;

    @Column(name = "flow_type", length = 10, nullable = false)
    private String flowType;

    @Column(name = "qty_g", nullable = false)
    private Integer qtyG;

    @Column(name = "remain_g")
    private Integer remainG;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "prescription_id")
    @JsonIgnore
    private Prescription prescription;

    @Column(length = 255)
    private String remark;

    @Column(name = "created_at", nullable = false)
    private java.time.LocalDateTime createdAt;
}

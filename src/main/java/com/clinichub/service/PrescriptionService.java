package com.clinichub.service;

import com.clinichub.entity.*;
import com.clinichub.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PrescriptionService {
    private final PrescriptionRepository prescriptionRepository;
    private final PrescriptionItemRepository itemRepository;
    private final VisitRepository visitRepository;
    private final HerbRepository herbRepository;
    private final StockFlowRepository stockFlowRepository;

    public List<Prescription> findAll() {
        return prescriptionRepository.findAllWithDetails();
    }

    public List<Prescription> findByVisit(Long visitId) {
        return prescriptionRepository.findByVisitId(visitId);
    }

    @Transactional
    public Prescription create(Prescription prescription) {
        Visit visit = visitRepository.findById(prescription.getVisit().getId()).orElseThrow();
        List<PrescriptionItem> items = prescription.getItems();

        prescription.setVisit(visit);
        prescription.setCreatedAt(LocalDateTime.now());
        if (prescription.getStatus() == null) prescription.setStatus("DRAFT");
        prescription.setItems(null);

        Prescription saved = prescriptionRepository.save(prescription);

        List<PrescriptionItem> savedItems = new ArrayList<>();
        if (items != null) {
            for (PrescriptionItem item : items) {
                Herb herb = herbRepository.findById(item.getHerb().getId()).orElseThrow();
                item.setHerb(herb);
                item.setPrescription(saved);
                savedItems.add(itemRepository.save(item));
            }
        }
        saved.setItems(savedItems);
        return prescriptionRepository.findByIdWithDetails(saved.getId()).orElse(saved);
    }

    @Transactional
    public Prescription dispense(Long id) {
        Prescription p = prescriptionRepository.findById(id).orElseThrow();
        if ("DISPENSED".equals(p.getStatus())) {
            throw new IllegalStateException("处方已发药，不能重复发药");
        }

        List<PrescriptionItem> items = itemRepository.findByPrescriptionId(id);
        int copies = p.getCopies() == null ? 1 : p.getCopies();

        for (PrescriptionItem item : items) {
            Herb herb = item.getHerb();
            int qty = item.getDoseG() * copies;
            int newStock = herb.getStockG() - qty;
            if (newStock < 0) {
                throw new IllegalStateException("药材库存不足: " + herb.getName());
            }
            herb.setStockG(newStock);
            herbRepository.save(herb);

            StockFlow flow = StockFlow.builder()
                    .herb(herb)
                    .flowType("OUT")
                    .qtyG(qty)
                    .remainG(newStock)
                    .prescription(p)
                    .remark("处方发药 #" + p.getId())
                    .createdAt(LocalDateTime.now())
                    .build();
            stockFlowRepository.save(flow);
        }
        p.setStatus("DISPENSED");
        prescriptionRepository.save(p);
        return prescriptionRepository.findByIdWithDetails(id).orElse(p);
    }
}

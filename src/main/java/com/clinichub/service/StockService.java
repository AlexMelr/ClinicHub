package com.clinichub.service;

import com.clinichub.entity.Herb;
import com.clinichub.entity.StockFlow;
import com.clinichub.repository.HerbRepository;
import com.clinichub.repository.StockFlowRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class StockService {
    private final StockFlowRepository stockFlowRepository;
    private final HerbRepository herbRepository;

    public List<StockFlow> findAll() {
        return stockFlowRepository.findAllWithHerb();
    }

    public List<StockFlow> findByHerb(Long herbId) {
        return stockFlowRepository.findByHerbIdOrderByCreatedAtDesc(herbId);
    }

    @Transactional
    public StockFlow stockIn(Long herbId, int qtyG, String remark) {
        Herb herb = herbRepository.findById(herbId).orElseThrow();
        int newStock = herb.getStockG() + qtyG;
        herb.setStockG(newStock);
        herbRepository.save(herb);

        StockFlow flow = StockFlow.builder()
                .herb(herb)
                .flowType("IN")
                .qtyG(qtyG)
                .remainG(newStock)
                .remark(remark)
                .createdAt(LocalDateTime.now())
                .build();
        return stockFlowRepository.save(flow);
    }
}

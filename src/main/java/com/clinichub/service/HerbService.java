package com.clinichub.service;

import com.clinichub.entity.Herb;
import com.clinichub.repository.HerbRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HerbService {
    private final HerbRepository herbRepository;

    public List<Herb> findAll() {
        return herbRepository.findByEnabledTrue();
    }

    public List<Herb> search(String keyword) {
        return herbRepository.findByNameContainingOrPinyinContaining(keyword, keyword);
    }

    public List<Herb> lowStock() {
        return herbRepository.findLowStock();
    }

    public Herb create(Herb herb) {
        herb.setCreatedAt(LocalDateTime.now());
        herb.setEnabled(true);
        return herbRepository.save(herb);
    }

    public Herb update(Long id, Herb update) {
        Herb herb = herbRepository.findById(id).orElseThrow();
        if (update.getName() != null) herb.setName(update.getName());
        if (update.getAliasName() != null) herb.setAliasName(update.getAliasName());
        if (update.getPinyin() != null) herb.setPinyin(update.getPinyin());
        if (update.getStockG() != null) herb.setStockG(update.getStockG());
        if (update.getUnit() != null) herb.setUnit(update.getUnit());
        if (update.getWarnThresholdG() != null) herb.setWarnThresholdG(update.getWarnThresholdG());
        return herbRepository.save(herb);
    }

    public void delete(Long id) {
        Herb herb = herbRepository.findById(id).orElseThrow();
        herb.setEnabled(false);
        herbRepository.save(herb);
    }
}

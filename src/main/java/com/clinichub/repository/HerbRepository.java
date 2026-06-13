package com.clinichub.repository;

import com.clinichub.entity.Herb;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface HerbRepository extends JpaRepository<Herb, Long> {
    Optional<Herb> findByName(String name);
    List<Herb> findByNameContainingOrPinyinContaining(String name, String pinyin);
    List<Herb> findByEnabledTrue();

    @Query("SELECT h FROM Herb h WHERE h.enabled = true AND h.stockG <= h.warnThresholdG")
    List<Herb> findLowStock();
}

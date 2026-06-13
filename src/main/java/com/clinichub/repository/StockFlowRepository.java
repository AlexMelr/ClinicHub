package com.clinichub.repository;

import com.clinichub.entity.StockFlow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface StockFlowRepository extends JpaRepository<StockFlow, Long> {
    @Query("SELECT s FROM StockFlow s JOIN FETCH s.herb WHERE s.herb.id = :herbId ORDER BY s.createdAt DESC")
    List<StockFlow> findByHerbIdOrderByCreatedAtDesc(@Param("herbId") Long herbId);
    
    @Query("SELECT s FROM StockFlow s JOIN FETCH s.herb ORDER BY s.createdAt DESC")
    List<StockFlow> findAllWithHerb();
}

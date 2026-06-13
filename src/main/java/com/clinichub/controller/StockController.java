package com.clinichub.controller;

import com.clinichub.entity.StockFlow;
import com.clinichub.service.StockService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/stock")
@RequiredArgsConstructor
public class StockController {
    private final StockService stockService;

    @GetMapping
    public List<StockFlow> list(@RequestParam(required = false) Long herbId) {
        if (herbId != null) return stockService.findByHerb(herbId);
        return stockService.findAll();
    }

    @PostMapping("/in")
    public StockFlow stockIn(@RequestBody Map<String, Object> body) {
        Long herbId = Long.valueOf(body.get("herbId").toString());
        int qty = Integer.parseInt(body.get("qtyG").toString());
        String remark = body.getOrDefault("remark", "").toString();
        return stockService.stockIn(herbId, qty, remark);
    }
}

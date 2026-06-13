package com.clinichub;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ClinicHubApiIntegrationTest {
    @Autowired
    private MockMvc mvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void coreClinicWorkflowWorks() throws Exception {
        long patientId = postJson("/api/patients", """
                {"name":"测试患者","age":42,"gender":"女","phone":"13800000000"}
                """).get("id").asLong();

        mvc.perform(get("/api/patients").param("keyword", "测试患者"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].id").value(patientId));

        long herbId = postJson("/api/herbs", """
                {"name":"测试甘草","aliasName":"国老","pinyin":"gancao","stockG":100,"unit":"g","warnThresholdG":90}
                """).get("id").asLong();

        postJson("/api/stock/in", """
                {"herbId":%d,"qtyG":20,"remark":"测试入库"}
                """.formatted(herbId));

        JsonNode visit = postJson("/api/visits", """
                {"patient":{"id":%d},"chiefComplaint":"头痛","diagnosis":"风寒","advice":"休息"}
                """.formatted(patientId));
        long visitId = visit.get("id").asLong();

        JsonNode prescription = postJson("/api/prescriptions", """
                {
                  "visit":{"id":%d},
                  "copies":2,
                  "usageText":"水煎服",
                  "items":[{"herb":{"id":%d},"doseG":15,"note":"后下"}]
                }
                """.formatted(visitId, herbId));
        long prescriptionId = prescription.get("id").asLong();

        mvc.perform(post("/api/prescriptions/{id}/dispense", prescriptionId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("DISPENSED"))
                .andExpect(jsonPath("$.items", hasSize(1)));

        mvc.perform(post("/api/prescriptions/{id}/dispense", prescriptionId))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("处方已发药，不能重复发药"));

        mvc.perform(get("/api/herbs/{id}", herbId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stockG").value(90));

        mvc.perform(get("/api/herbs").param("lowStock", "true"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(herbId));

        mvc.perform(get("/api/stock").param("herbId", String.valueOf(herbId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)));
    }

    private JsonNode postJson(String path, String body) throws Exception {
        String content = mvc.perform(post(path)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        return objectMapper.readTree(content);
    }
}

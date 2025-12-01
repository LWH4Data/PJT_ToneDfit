package com.example.tone_d_fit_dev.ApiTestOnly.Controller;

import com.example.tone_d_fit_dev.ApiTestOnly.Domain.TestEntity;
import com.example.tone_d_fit_dev.ApiTestOnly.Service.TestService;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/test")
public class TestController {

    private final TestService testService;

    public TestController(TestService testService) {
        this.testService = testService;
    }

    @GetMapping("/hello")
    public String getHello() {
        return "Hello test is successful !!";
    }

    @GetMapping("/status")
    public String statusCheck() {
        return "OK";
    }

    @GetMapping("/find/{id}")
    public TestEntity getTestContent(@PathVariable Long id) {
        return testService.getContent(id);
    }
}

package io.wickline.portfolio.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PortfolioController {
    @GetMapping("/")
    public String get(ModelMap modelMap) {
        modelMap.addAttribute("name", "Tyler Wickline");
        return "portfolio";
    }
}

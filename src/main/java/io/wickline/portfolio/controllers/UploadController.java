package io.wickline.portfolio.controllers;

import io.wickline.portfolio.services.UploadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.Objects;

@Controller
@RequestMapping("/upload")
public class UploadController {
    @Autowired
    UploadService uploadService;

    @GetMapping()
    public String upload() {
        return "upload";
    }

    @PostMapping()
    public String postUpload(@RequestParam("file") MultipartFile file, ModelMap modelMap) {
        try {
            File name = uploadService.uploadFile(file);
            modelMap.addAttribute("file", name);
        } catch (IOException e) {
            e.printStackTrace();
        }
        //TODO Store file
        return "upload";
    }
    //TODO:     Hash file and check if its the same.
    //TODO:     Build Service to run script on file
    //TODO:     Return file
}


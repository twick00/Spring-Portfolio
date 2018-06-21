package io.wickline.portfolio.services;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;
import org.springframework.util.IdGenerator;
import org.springframework.util.SimpleIdGenerator;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

@Service
@Scope("singleton")
public class UploadService {
    private IdGenerator idGenerator = new SimpleIdGenerator();

    public File uploadFile(MultipartFile file) throws IOException {
        String name = idGenerator.generateId().toString();
        File newLocation = Files.createTempFile(name, ".n64").toFile();
        file.transferTo(newLocation);
        System.out.println(newLocation.getPath());
        return newLocation;
    }
    public void buildFile(File file) {
        //TODO Run CLI Script on file
    }
}

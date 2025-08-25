package goma.gorilla.backend.model;

import goma.gorilla.backend.model.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.HashSet;
import java.util.Set;

// Permission Entity
@Entity
@Table(name = "permissions")
public class Permission extends BaseEntity {

    @NotBlank
    @Size(max = 100)
    @Column(name = "key", nullable = false, unique = true)
    private String key;

    @NotBlank
    @Size(max = 100)
    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description", length = 500)
    private String description;

    @Size(max = 50)
    @Column(name = "module")
    private String module;

    // Constructors
    public Permission() {}

    public Permission(String key, String name) {
        this.key = key;
        this.name = name;
    }

    // Getters and Setters
    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getModule() {
        return module;
    }

    public void setModule(String module) {
        this.module = module;
    }

    @Override
    public String toString() {
        return "Permission{" +
                "id=" + getId() +
                ", key='" + key + '\'' +
                ", name='" + name + '\'' +
                '}';
    }
}
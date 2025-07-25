// ✅ Add this block at the top
plugins {
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

buildscript {
    dependencies {
        // ✅ Add Kotlin plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
        // ✅ Google Services plugin
        classpath("com.google.gms:google-services:4.3.15")
    }

    repositories {
        google() // Google's Maven repository
        mavenCentral() // Maven Central repository
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

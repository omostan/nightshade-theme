import org.gradle.api.plugins.ExtensionAware
import org.gradle.kotlin.dsl.withGroovyBuilder

plugins {
    id("org.jetbrains.intellij.platform") version "2.13.1"
}
group = providers.gradleProperty("pluginGroup").get()
version = providers.gradleProperty("pluginVersion").get()
repositories {
    mavenCentral()
    (this as ExtensionAware).extensions.getByName("intellijPlatform").withGroovyBuilder {
        "defaultRepositories"()
    }
}
dependencies {
    (this as ExtensionAware).extensions.getByName("intellijPlatform").withGroovyBuilder {
        "create"(providers.gradleProperty("platformType").get(), providers.gradleProperty("platformVersion").get())
        // Theme-only plugin: skip downloading sources
        "bundledPlugins"("com.intellij.platform.images")
    }
}
// Declare Java 21 (LTS) as the project's Java toolchain.
// This aligns the local build with CI (actions/setup-java java-version: '21')
// and Qodana (projectJDK: "21") configurations.
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

// Point the resources source set at the project's top-level resources/ folder
// so Gradle packages it exactly the same way IntelliJ IDEA's artifact builder does.
sourceSets {
    main {
        resources {
            srcDirs("resources")
        }
    }
}
tasks {
    // No Java sources to compile
    compileJava { enabled = false }
    compileTestJava { enabled = false }
    // Building searchable options requires the IDE to run — unnecessary for a theme.
    // prepareJarSearchableOptions is also disabled to prevent Gradle 9's strict
    // @InputDirectory validation failure on clean builds (it expects buildSearchableOptions'
    // output directory which never exists when the upstream task is disabled).
    buildSearchableOptions { enabled = false }
    named("prepareJarSearchableOptions") { enabled = false }
}
// Plugin signing — credentials supplied via environment variables / GitHub Secrets
extensions.getByName("intellijPlatform").withGroovyBuilder {
    "signing" {
        setProperty("certificateChain", providers.environmentVariable("CERTIFICATE_CHAIN"))
        setProperty("privateKey", providers.environmentVariable("PRIVATE_KEY"))
        setProperty("password", providers.environmentVariable("PRIVATE_KEY_PASSWORD"))
    }
    // JetBrains Marketplace publishing — token supplied via environment variable / GitHub Secret
    "publishing" {
        setProperty("token", providers.environmentVariable("PUBLISH_TOKEN"))
    }
}

plugins {
    id("org.jetbrains.intellij") version "1.17.4"
}
group = providers.gradleProperty("pluginGroup").get()
version = providers.gradleProperty("pluginVersion").get()
repositories {
    mavenCentral()
}
intellij {
    version.set(providers.gradleProperty("platformVersion").get())
    type.set(providers.gradleProperty("platformType").get())
    // Theme-only plugin: skip sources and since/until-build patching
    downloadSources.set(false)
    updateSinceUntilBuild.set(false)
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
    // Building searchable options requires the IDE to run — unnecessary for a theme
    buildSearchableOptions { enabled = false }
    // Plugin signing — credentials supplied via environment variables / GitHub Secrets
    signPlugin {
        certificateChain.set(providers.environmentVariable("CERTIFICATE_CHAIN"))
        privateKey.set(providers.environmentVariable("PRIVATE_KEY"))
        password.set(providers.environmentVariable("PRIVATE_KEY_PASSWORD"))
    }
    // JetBrains Marketplace publishing — token supplied via environment variable / GitHub Secret
    publishPlugin {
        token.set(providers.environmentVariable("PUBLISH_TOKEN"))
    }
}

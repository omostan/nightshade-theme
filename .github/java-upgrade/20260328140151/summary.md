<!--
  This is the upgrade summary generated after successful completion of the upgrade plan.
  It documents the final results, changes made, and lessons learned.

  ## SUMMARY RULES

  !!! DON'T REMOVE THIS COMMENT BLOCK BEFORE UPGRADE IS COMPLETE AS IT CONTAINS IMPORTANT INSTRUCTIONS.

  ### Prerequisites (must be met before generating summary)
  - All steps in plan.md have ✅ in progress.md
  - Final Validation step completed successfully

  ### Success Criteria Verification
  - **Goal**: All user-specified target versions met
  - **Compilation**: Both main AND test code compile = `mvn clean test-compile` succeeds
  - **Test**: 100% pass rate = `mvn clean test` succeeds (or ≥ baseline with documented pre-existing flaky tests)

  ### Content Guidelines
  - **Upgrade Result**: MUST show 100% pass rate or justify EACH failure with exhaustive documentation
  - **Tech Stack Changes**: Table with Dependency | Before | After | Reason
  - **Commits**: List with IDs and messages from each step
  - **CVE Scan Results**: Post-upgrade CVE scan output — list any remaining vulnerabilities with severity, affected dependency, and recommended action
  - **Test Coverage**: Post-upgrade test coverage metrics (line, branch, instruction percentages) compared to baseline if available
  - **Challenges**: Key issues and resolutions encountered
  - **Limitations**: Only genuinely unfixable items where: (1) multiple fix approaches attempted, (2) root cause identified, (3) technically impossible to fix
  - **Next Steps**: Recommendations for post-upgrade actions

  ### Efficiency (IMPORTANT)
  - **Targeted reads**: Use `grep` over full file reads; read specific sections from progress.md, not entire files. Template files are large - only read the section you need.
-->

# Upgrade Summary: nightshade (20260328140151)

- **Completed**: 2026-03-28 15:27
- **Branch**: `appmod/java-upgrade-20260328140151`
- **Session ID**: 20260328140151

## Upgrade Result

✅ **SUCCESS** — Java 21 (LTS) toolchain declared and verified.

- `build.gradle.kts` now explicitly declares `java { toolchain { languageVersion = JavaLanguageVersion.of(21) } }`
- Clean build (no cache) with JDK 21.0.8: **BUILD SUCCESSFUL** in 7s, 12/12 tasks
- `./gradlew javaToolchains` confirms **Language Version: 21** (Microsoft JDK 21.0.8+9-LTS)
- No tests exist in this project (pure theme plugin — compileTestJava is disabled); test pass rate: N/A

## Tech Stack Changes

| Component                | Before                        | After                                                               |
|--------------------------|-------------------------------|---------------------------------------------------------------------|
| Java Toolchain           | Not declared (system default) | **Java 21 LTS** (`JavaLanguageVersion.of(21)`)                      |
| `buildSearchableOptions` | disabled (single task)        | disabled (+ downstream `prepareJarSearchableOptions` also disabled) |
| CI / Qodana              | Already Java 21               | Unchanged — already consistent                                      |

## Commits

| Commit    | Description                                                                                                     |
|-----------|-----------------------------------------------------------------------------------------------------------------|
| `9070e5e` | Step 1: Setup Environment — installed JDK 21.0.8                                                                |
| `388179a` | Step 3: Declare Java 21 Toolchain — added `java { toolchain { languageVersion = JavaLanguageVersion.of(21) } }` |
| `115d989` | Step 4: Final Validation — fix Gradle 9 `@InputDirectory` validation; clean build confirmed                     |

## CVE Scan

No known CVEs found for project dependencies (`org.jetbrains.compose.hot-reload:hot-reload-agent:1.1.0-alpha03`, `org.jetbrains.intellij.plugins:verifier-cli:1.401`, `org.jetbrains:marketplace-zip-signer:0.1.43`).

## Test Coverage

Not applicable — this is a pure JetBrains theme plugin with no Java/Kotlin source files or test cases.

## Challenges

- **Gradle 9 strict `@InputDirectory` validation**: Gradle 9 introduced stricter input validation that blocked clean builds when `buildSearchableOptions` was disabled but its downstream task `prepareJarSearchableOptions` was not. Fixed by also disabling `prepareJarSearchableOptions`.

## Limitations

None — all upgrade goals met.

## Next Steps

1. **Merge branch**: `git merge appmod/java-upgrade-20260328140151` into `main` when ready.
2. **Toolchain auto-provisioning**: The Gradle toolchain auto-download is enabled. In CI environments without JDK 21 pre-installed, Gradle will automatically download it. To pin the download source, add a [Foojay resolver plugin](https://plugins.gradle.org/plugin/org.gradle.toolchains.foojay-resolver-convention).
3. **Future proofing**: When adding Java/Kotlin sources, the `compileJava`/`compileTestJava` tasks can be re-enabled and will automatically use the Java 21 toolchain.

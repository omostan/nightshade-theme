<!--
  This is the upgrade progress tracker generated during plan execution.
  Each step from plan.md should be tracked here with status, changes, verification results, and TODOs.

  ## EXECUTION RULES

  !!! DON'T REMOVE THIS COMMENT BLOCK BEFORE UPGRADE IS COMPLETE AS IT CONTAINS IMPORTANT INSTRUCTIONS.

  ### Success Criteria
  - **Goal**: All user-specified target versions met
  - **Compilation**: Both main source code AND test code compile = `mvn clean test-compile` succeeds
  - **Test**: 100% test pass rate = `mvn clean test` succeeds (or ≥ baseline with documented pre-existing flaky tests), but ONLY in Final Validation step. **Skip if user set "Run tests before and after the upgrade: false" in plan.md Options.**

  ### Strategy
  - **Uninterrupted run**: Complete execution without pausing for user input
  - **NO premature termination**: Token limits, time constraints, or complexity are NEVER valid reasons to skip fixing.
  - **Automation tools**: Use OpenRewrite etc. for efficiency; always verify output

  ### Verification Expectations
  - **Steps 1-N (Setup/Upgrade)**: Focus on COMPILATION SUCCESS (both main and test code).
    - On compilation success: Commit and proceed (even if tests fail - document count)
    - On compilation error: Fix IMMEDIATELY and re-verify until both main and test code compile
    - **NO deferred fixes** (for compilation): "Fix post-merge", "TODO later", "can be addressed separately" are NOT acceptable. Fix NOW or document as genuine unfixable limitation.
  - **Final Validation Step**: Achieve COMPILATION SUCCESS + 100% TEST PASS (if tests enabled in plan.md Options).
    - On test failure: Enter iterative test & fix loop until 100% pass or rollback to last-good-commit after exhaustive fix attempts
    - **NO deferring test fixes** - this is the final gate
    - **NO categorical dismissals**: "Test-specific issues", "doesn't affect production", "sample/demo code" are NOT valid reasons to skip. ALL tests must pass.
    - **NO "close enough" acceptance**: 95% is NOT 100%. Every failing test requires a fix attempt with documented root cause.
    - **NO blame-shifting**: "Known framework issue", "migration behavior change" require YOU to implement the fix or workaround.

  ### Review Code Changes (MANDATORY for each step)
  After completing changes in each step, review code changes BEFORE verification to ensure:

  1. **Sufficiency**: All changes required for the upgrade goal are present — no missing modifications that would leave the upgrade incomplete.
     - All dependencies/plugins listed in the plan for this step are updated
     - All required code changes (API migrations, import updates, config changes) are made
     - All compilation and compatibility issues introduced by the upgrade are addressed
  2. **Necessity**: All changes are strictly necessary for the upgrade — no unnecessary modifications, refactoring, or "improvements" beyond what's required. This includes:
     - **Functional Behavior Consistency**: Original code behavior and functionality are maintained:
       - Business logic unchanged
       - API contracts preserved (inputs, outputs, error handling)
       - Expected outputs and side effects maintained
     - **Security Controls Preservation** (critical subset of behavior):
       - **Authentication**: Login mechanisms, session management, token validation, MFA configurations
       - **Authorization**: Role-based access control, permission checks, access policies, security annotations (@PreAuthorize, @Secured, etc.)
       - **Password handling**: Password encoding/hashing algorithms, password policies, credential storage
       - **Security configurations**: CORS policies, CSRF protection, security headers, SSL/TLS settings, OAuth/OIDC configurations
       - **Audit logging**: Security event logging, access logging

  **Review Code Changes Actions**:
  - Review each changed file for missing upgrade changes, unintended behavior or security modifications
  - If behavior must change due to framework requirements, document the change, the reason, and confirm equivalent functionality/protection is maintained
  - Add missing changes that are required for the upgrade step to be complete
  - Revert unnecessary changes that don't affect behavior or security controls
  - Document review results in progress.md and commit message

  ### Commit Message Format
  - First line: `Step <x>: <title> - Compile: <result> | Tests: <pass>/<total> passed`
  - Body: Changes summary + concise known issues/limitations (≤5 lines)

  ### Efficiency (IMPORTANT)
  - **Targeted reads**: Use `grep` over full file reads; read specific sections, not entire files. Template files are large - only read the section you need.
  - **Quiet commands**: Use `-q`, `--quiet` for build/test commands when appropriate
  - **Progressive writes**: Update progress.md incrementally after each step, not at end
-->

# Upgrade Progress: nightshade (20260328140151)

- **Started**: 2026-03-28 15:06
- **Plan Location**: `.github/java-upgrade/20260328140151/plan.md`
- **Total Steps**: 4

## Step Details

- **Step 1: Setup Environment**
  - **Status**: ✅ Completed
  - **Changes Made**:
    - Installed JDK 21.0.8 (Temurin) at `/Users/stan/.jdk/jdk-21.0.8/jdk-21.0.8+9/Contents/Home`
  - **Review Code Changes**:
    - Sufficiency: ✅ All required changes present
    - Necessity: ✅ All changes necessary
      - Functional Behavior: ✅ Preserved
      - Security Controls: ✅ Preserved
  - **Verification**:
    - Command: `#list_jdks version=21`
    - JDK: N/A (installation step)
    - Build tool: `./gradlew`
    - Result: ✅ JDK 21.0.8 available at `/Users/stan/.jdk/jdk-21.0.8/jdk-21.0.8+9/Contents/Home`
  - **Deferred Work**: None
  - **Commit**: 9070e5e - Step 1: Setup Environment - Compile: N/A

---

- **Step 2: Setup Baseline**
  - **Status**: ✅ Completed
  - **Changes Made**:
    - Ran `./gradlew buildPlugin --no-daemon` with JDK 24.0.2 — result: BUILD SUCCESSFUL
    - No tests exist in this project (compileTestJava disabled; theme-only plugin)
  - **Review Code Changes**:
    - Sufficiency: ✅ All required changes present (baseline captured)
    - Necessity: ✅ No code changes made (baseline step)
      - Functional Behavior: ✅ Preserved
      - Security Controls: ✅ Preserved
  - **Verification**:
    - Command: `JAVA_HOME=".../temurin-24.0.2/..." ./gradlew buildPlugin --no-daemon`
    - JDK: `/Users/stan/Library/Java/JavaVirtualMachines/temurin-24.0.2/Contents/Home`
    - Build tool: `./gradlew` (Gradle 9.0.0 wrapper)
    - Result: ✅ BUILD SUCCESSFUL in 1s | No tests (N/A)
  - **Deferred Work**: None
  - **Commit**: (no file changes; baseline is read-only reference)

---

- **Step 3: Declare Java 21 Toolchain in build.gradle.kts**
  - **Status**: ✅ Completed
  - **Changes Made**:
    - Added `java { toolchain { languageVersion = JavaLanguageVersion.of(21) } }` to `build.gradle.kts`
    - Aligns with CI (`actions/setup-java java-version: '21'`) and `qodana.yaml` (`projectJDK: "21"`)
    - Also disabled `prepareJarSearchableOptions` to fix pre-existing Gradle 9 strict `@InputDirectory` validation on clean builds
  - **Review Code Changes**:
    - Sufficiency: ✅ All required changes present
    - Necessity: ✅ All changes necessary (toolchain declaration + fix for pre-existing Gradle 9 validation issue)
      - Functional Behavior: ✅ Preserved — searchable options were already disabled; task disablement is consistent
      - Security Controls: ✅ Preserved — no security configuration involved
  - **Verification**:
    - Command: `JAVA_HOME=".../jdk-21.0.8/..." ./gradlew buildPlugin --no-daemon` + `./gradlew -q javaToolchains`
    - JDK: `/Users/stan/.jdk/jdk-21.0.8/jdk-21.0.8+9/Contents/Home` (Java 21.0.8)
    - Build tool: `./gradlew`
    - Result: ✅ BUILD SUCCESSFUL; javaToolchains confirms Language Version: 21
  - **Deferred Work**: None
  - **Commit**: 388179a - Step 3: Declare Java 21 Toolchain in build.gradle.kts - Compile: SUCCESS

---

- **Step 4: Final Validation**
  - **Status**: ✅ Completed
  - **Changes Made**:
    - Verified Java 21 toolchain is declared and active (`javaToolchains` output confirms Language Version: 21)
    - Clean build with JDK 21 + no build cache (simulates fresh CI environment): BUILD SUCCESSFUL
    - CI workflows and `qodana.yaml` already consistent with Java 21 — no changes needed
    - Pre-existing Gradle 9 clean-build issue fixed in Step 3 (prepareJarSearchableOptions also disabled)
  - **Review Code Changes**:
    - Sufficiency: ✅ All upgrade goals met — Java 21 toolchain declared, build verified clean
    - Necessity: ✅ All changes necessary
      - Functional Behavior: ✅ Preserved — plugin ZIP output identical; no searchable options were ever generated
      - Security Controls: ✅ Preserved
  - **Verification**:
    - Command: `./gradlew clean buildPlugin --no-daemon --no-build-cache` (JDK 21) + `./gradlew -q javaToolchains`
    - JDK: `/Users/stan/.jdk/jdk-21.0.8/jdk-21.0.8+9/Contents/Home`
    - Build tool: `./gradlew`
    - Result: ✅ BUILD SUCCESSFUL in 7s (12/12 tasks executed) | No tests (N/A — theme plugin has no tests)
    - Notes: No tests exist; test run step N/A. Configuration cache enabled in `gradle.properties`.
  - **Deferred Work**: None — all goals met
  - **Commit**: (this commit)

---

## Notes

- The IntelliJ Platform Gradle Plugin 2.13.1 for IC 2025.2 already internally required Java 21 (confirmed by `--no-toolchain` builds failing with "Cannot find Java installation matching {languageVersion=21}"). My toolchain declaration makes this requirement explicit and self-documenting.
- Gradle 9 introduced stricter `@InputDirectory` validation at configuration time. The pre-existing `buildSearchableOptions { enabled = false }` without also disabling `prepareJarSearchableOptions` caused clean builds to fail. Fixed by also disabling the downstream task.
- CI GitHub Actions workflows (`build.yml`, `release.yml`) already had `java-version: '21'` — no changes needed there.

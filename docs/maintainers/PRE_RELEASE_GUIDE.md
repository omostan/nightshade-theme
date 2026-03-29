# Pre-Release Build & Validation Guide

## Overview

The `pre-release.sh` script automates the plugin build and release validation process. It combines two steps into one convenient command and mirrors everything to a log file while still streaming output to the terminal:

1. **Build Phase**: Compiles the plugin using Gradle (`./gradlew buildPlugin`)
2. **Validation Phase**: Verifies that generated artifacts meet release requirements

## Quick Start

```bash
./pre-release.sh
```

Run from the project root directory. The script supports `-h` / `--help` and rejects any other extra arguments.

### Logging

- Live output stays visible in the terminal.
- The same output is also written to `build/reports/pre-release/latest.log`.
- A timestamped archive is also created per run, for example: `build/reports/pre-release/pre-release-20260326-201530.log`.
- Legacy `build/reports/pre-release/pre-release.log` files are automatically cleaned up at script start.
- Because these logs live under `build/`, they are already ignored by Git.

## What It Does

### Phase 1: Build with Gradle
- Executes `./gradlew buildPlugin`
- Generates:
  - JAR file in `build/libs/nightshade-*.jar`
  - ZIP file in `build/distributions/nightshade-*.zip`
- Stops and reports error if build fails (exit code: 1)

### Phase 2: Validate Artifacts
Performs 5 automatic checks:

1. **JAR exists**: Confirms JAR file was created in `build/libs/` or `out/artifacts/`
2. **plugin.xml**: Validates plugin descriptor is packaged in JAR
3. **theme files**: Ensures `theme/nightshade.theme.json` and `theme/nightshade.xml` are present
4. **icon+images**: Verifies `META-INF/pluginIcon.svg` and image assets are included
5. **ZIP exists**: Confirms distribution ZIP was created for marketplace publishing

After validation, the script prints an exact artifact summary showing:

- the Gradle-generated release JAR path
- the IDE artifact JAR path (if it exists)
- the Gradle-generated ZIP path
- which JAR was actually used for validation
- the latest log path
- the archived timestamped log path

## Exit Codes

| Code | Meaning                 | Action                                               |
|------|-------------------------|------------------------------------------------------|
| `0`  | Build + Validation PASS | Ready to release ✓                                   |
| `1`  | Build FAILED            | Fix Gradle errors, re-run script                     |
| `2`  | Validation FAILED       | Fix artifact issues (see validation output)          |
| `64` | Invalid usage           | Remove extra arguments and re-run `./pre-release.sh` |

## Example Output

**Success:**
```
============================================
Pre-Release Build & Validation
============================================

Working directory: /d/Tutorials/JetBrains/Plugins/Themes/nightshade
Latest log: build/reports/pre-release/latest.log
Archived log: build/reports/pre-release/pre-release-20260326-201530.log

[Phase 1/2] Building plugin with Gradle...

> Task :compileJava SKIPPED
> Task :processResources
> Task :classes
> Task :jar
> Task :buildPlugin
BUILD SUCCESSFUL in 2s

✓ Gradle build completed successfully

[Phase 2/2] Validating release artifacts...

Progress: ████████████████████████████████████████ 5/5
1 JAR exists: PASS
2 plugin.xml: PASS
3 theme files: PASS
4 icon+images: PASS
5 ZIP exists: PASS

Artifact Summary
  Gradle JAR: build/libs/nightshade-1.0.1.jar
  IDE artifact JAR: out/artifacts/nightshade_jar/nightshade.jar
  Release ZIP: build/distributions/nightshade-1.0.1.zip
  Validation source JAR: build/libs/nightshade-1.0.1.jar
  Latest log: build/reports/pre-release/latest.log
  Archived log: build/reports/pre-release/pre-release-20260326-201530.log

============================================
✓ OVERALL: PASS
Plugin is ready for release!
============================================
```

**Failure (Build):**
```
[Phase 1/2] Building plugin with Gradle...

> Task :compileJava FAILED
...build error details...

✗ Gradle build failed
Exit code: 1
```

**Failure (Validation):**
```
[Phase 2/2] Validating release artifacts...

Progress: ████████████████████████████████████████ 5/5
1 JAR exists: PASS
2 plugin.xml: FAIL
3 theme files: PASS
4 icon+images: PASS
5 ZIP exists: PASS

============================================
✗ OVERALL: FAIL
Please fix validation errors before release.
============================================
```

## Usage Workflow

### Before Release

1. **Prepare changes**
   ```bash
   git add -A
   git commit -m "Prepare release v1.0.2"
   ```

2. **Run pre-release validation**
   ```bash
   ./pre-release.sh
   ```

3. **Verify output**
   - Look for `✓ OVERALL: PASS`
   - Check exit code: `echo $?` should print `0`

4. **If PASS**: Proceed to publish
   - ZIP file: `build/distributions/nightshade-*.zip`
   - JAR file: `build/libs/nightshade-*.jar`

5. **If FAIL**: Fix errors and re-run
   - Address Gradle build errors (Phase 1)
   - Or troubleshoot artifact content (Phase 2)

### Invalid Usage Example

```bash
./pre-release.sh buildPlugin
```

Output:

```text
Error: unexpected argument(s): buildPlugin

Usage: ./pre-release.sh

Builds the plugin with Gradle, validates the generated artifacts, and writes
the full terminal output to:
  - build/reports/pre-release/latest.log
  - build/reports/pre-release/pre-release-YYYYMMDD-HHMMSS.log

Options:
  -h, --help   Show this help and exit.

This script accepts no positional arguments.
```

### Help Example

```bash
./pre-release.sh --help
```

### CI/CD Integration

Use exit codes in automated pipelines:

```yaml
# GitHub Actions example
- name: Pre-release Check
  run: bash pre-release.sh
  
- name: Publish
  if: success()
  run: ./gradlew publishPlugin
```

## Troubleshooting

### "Gradle build failed"
- Check error output above
- Review the full log in `build/reports/pre-release/latest.log` (or the timestamped archived log for that run)
- Ensure Java/JDK is installed
- Try: `./gradlew clean buildPlugin`

### "JAR exists: FAIL"
- Verify build completed: check `build/libs/` folder manually
- Try: `ls -la build/libs/nightshade*.jar`

### "plugin.xml: FAIL" / "theme files: FAIL"
- Verify `src/main/resources/META-INF/plugin.xml` exists
- Verify `src/main/resources/theme/` files exist
- Check artifact configuration in `.idea/artifacts/nightshade_jar.xml`

### "ZIP exists: FAIL"
- Confirm `build/distributions/` folder exists
- Try: `ls -la build/distributions/`
- Ensure `buildPlugin` task completed in Phase 1

### "unexpected argument(s)"
- Run the script without arguments:
  ```bash
  ./pre-release.sh
  ```

### Expected `./gradlew runIde` warnings

When launching the sandbox IDE with `./gradlew runIde`, the following warnings can appear even when the run is healthy:

- `Archived non-system classes are disabled because the java.system.class.loader property is specified`
  - Expected for IntelliJ Platform runs that use `com.intellij.util.lang.PathClassLoader`
  - This is a JVM/Class Data Sharing optimization warning, not a plugin failure
- `Bundled shared index is not found at: ...\jdk-shared-indexes`
  - Usually means the downloaded IDE distribution does not include a bundled JDK shared index cache at that path
  - This may affect startup or indexing performance, but it does not block theme/plugin development

Treat both messages as benign unless `runIde` itself exits with an error, the sandbox IDE fails to start, or the warning text changes in a way that points to a real missing dependency or corrupted IDE download.

## Related Files

- **Build script**: `build.gradle.kts`
- **Manual validation script**: `release-check.sh` (same validation, no build)
- **Pre-release logs**: `build/reports/pre-release/latest.log` and `build/reports/pre-release/pre-release-YYYYMMDD-HHMMSS.log`
- **Release checklist**: `docs/maintainers/NEXT_RELEASE_CHECKLIST.md`
- **Publishing guide**: `docs/maintainers/SIGNING_AND_PUBLISHING.md`

## See Also

- Run **validation only** (no build): `bash release-check.sh`
- Run **build only** (no validation): `./gradlew buildPlugin`
- Run **IDE** (no build): `./gradlew runIde` or use the shared IntelliJ run configuration `Run IDE (Gradle runIde)`

## Questions?

Refer to:
- `docs/maintainers/README.md` - Team workflows
- `docs/maintainers/NEXT_RELEASE_CHECKLIST.md` - Full release process
- `README.md` - Plugin overview


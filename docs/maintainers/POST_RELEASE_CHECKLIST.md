# Post-Release Checklist

Use this checklist immediately after pushing `vX.Y.Z` and after the `Release` workflow completes.

## 1) Verify GitHub release artifacts

- Confirm the `Release` workflow run succeeded for the tag.
- Open the GitHub Release for `vX.Y.Z` and verify:
  - release title/version is correct,
  - generated notes/body looks good,
  - plugin ZIP artifact is attached and downloadable.

## 2) Verify JetBrains Marketplace status

- Confirm the plugin version appears in Marketplace (if publish step ran).
- Check listing metadata (version, change notes, compatibility range) is accurate.
- Confirm there are no signing/publishing errors in workflow logs.

## 3) Smoke-test install/upgrade

- In a clean IDE profile, install/upgrade to `vX.Y.Z`.
- Verify the theme appears and applies successfully.
- Verify no startup/plugin errors are reported in IDE logs.

## 4) Repository hygiene

- Confirm `CHANGELOG.md` and `src/main/resources/META-INF/plugin.xml` match the released version.
- Confirm `gradle.properties` `pluginVersion` is aligned with the latest release.
- Add any release follow-up tasks to Issues (if needed).

## 5) Communication

- Share release notes link with users/contributors.
- Highlight user-visible fixes/features and compatibility updates.


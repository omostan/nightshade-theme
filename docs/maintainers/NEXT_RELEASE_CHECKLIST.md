# When You Should Release Next Time

1. Bump `pluginVersion` in `gradle.properties`.
2. Update release notes in `CHANGELOG.md` and `src/main/resources/META-INF/plugin.xml` (`change-notes`).
3. Commit.
4. Create matching tag `v<same-version>`.
5. Push commit + tag to trigger Marketplace publish workflow.

```bash
git add -A
git commit -m "chore(release): bump version to X.Y.Z"
git tag vX.Y.Z
git push
git push origin vX.Y.Z
```


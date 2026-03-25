# Signing and Publishing Secrets Setup

This guide walks through how to set up the signing and publishing secrets for the **Nightshade Theme** JetBrains plugin.

These secrets are used by the release workflow in [`../../.github/workflows/release.yml`](../../.github/workflows/release.yml) and by the Gradle tasks in [`../../build.gradle.kts`](../../build.gradle.kts).

## Secret names used by this project

| Secret | Required | Purpose |
|---|---|---|
| `CERTIFICATE_CHAIN` | Yes | PEM-encoded certificate used for plugin signing |
| `PRIVATE_KEY` | Yes | PEM-encoded private key used for plugin signing |
| `PRIVATE_KEY_PASSWORD` | Only if your key is encrypted | Passphrase for the private key |
| `PUBLISH_TOKEN` | Yes | JetBrains Marketplace token used to publish the plugin |

> If your private key is **not encrypted**, you do **not** need to create `PRIVATE_KEY_PASSWORD`.

---

## 1. Generate plugin signing credentials

You need a signing certificate and private key for the JetBrains plugin signing step.

### Option A: Generate a self-signed certificate

```bash
openssl genrsa -out private.pem 2048
openssl req -new -x509 -key private.pem -out certificate.pem -days 365
```

This creates:

- `private.pem` — your private key
- `certificate.pem` — your certificate

When prompted during `openssl req`, you can fill in your organization details. A simple Common Name like `nightshade-theme` is fine.

### Option B: Use an existing certificate

If you already have a certificate and private key that you use for plugin signing, you can use those instead.

---

## 2. Extract the certificate and private key content

You will store the full PEM contents in GitHub Actions secrets.

### Windows PowerShell

```powershell
Get-Content .\certificate.pem -Raw
Get-Content .\private.pem -Raw
```

### Git Bash / bash

```bash
cat certificate.pem
cat private.pem
```

Copy the **entire content** of each file, including the `-----BEGIN ...-----` and `-----END ...-----` lines.

---

## 3. Generate a JetBrains Marketplace publish token

1. Sign in to [JetBrains Hub](https://hub.jetbrains.com/users/me).
2. Open **Settings** → **Tokens**.
3. Create a new permanent token.
4. Name it something like `NIGHTSHADE_MARKETPLACE_PUBLISH`.
5. Copy the token value.

You will store this value as `PUBLISH_TOKEN` in GitHub.

---

## 4. Add the secrets to your GitHub repository

In your GitHub repository:

1. Open **Settings**.
2. Go to **Secrets and variables** → **Actions**.
3. Click **New repository secret**.
4. Add the following secrets:

| Name | Value |
|---|---|
| `CERTIFICATE_CHAIN` | Full contents of `certificate.pem` |
| `PRIVATE_KEY` | Full contents of `private.pem` |
| `PUBLISH_TOKEN` | Your JetBrains Marketplace token |
| `PRIVATE_KEY_PASSWORD` | Only add this if your private key is encrypted |

> Repository secrets are enough for the current workflow. You only need **environment secrets** if you later move this release job into a protected GitHub Environment.

---

## 5. Confirm the release workflow uses those secrets

The release workflow reads these values from GitHub Actions secrets.

Current release steps:

- `Sign plugin`
- `Publish plugin to Marketplace`

They use these environment variables:

```yaml
env:
  CERTIFICATE_CHAIN: ${{ secrets.CERTIFICATE_CHAIN }}
  PRIVATE_KEY: ${{ secrets.PRIVATE_KEY }}
  PRIVATE_KEY_PASSWORD: ${{ secrets.PRIVATE_KEY_PASSWORD }}
  PUBLISH_TOKEN: ${{ secrets.PUBLISH_TOKEN }}
```

If `PRIVATE_KEY_PASSWORD` does not exist and your key is not encrypted, the workflow can still run successfully.

---

## 6. Trigger and test a release

### JDK note for maintainers

- Run Gradle sync/build with **JDK 21**.
- `Project SDK` can still be higher.

1. Update `pluginVersion` in [`../../gradle.properties`](../../gradle.properties).
2. Commit the version change.
3. Create a Git tag with the same version and a `v` prefix.
4. Push the tag.

Example:

```bash
git add gradle.properties
git commit -m "chore: release v1.0.2"
git tag v1.0.2
git push origin main --tags
```

The release workflow will:

1. Build the plugin ZIP
2. Validate that the Git tag matches `pluginVersion`
3. Create a GitHub Release
4. Sign the plugin
5. Publish it to JetBrains Marketplace

---

## Security notes

- **Do not commit** `private.pem` or `certificate.pem` to the repository.
- Add them to `.gitignore` if they exist locally.
- If a private key is ever exposed publicly, rotate it before future releases.



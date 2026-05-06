# Offline VSCode Setup

Use this setup when you do not want VSCode to depend on GitHub login, Copilot, Settings Sync, or macOS Keychain.

## Runtime flags

The launcher uses:

```bash
--password-store=basic
--use-inmemory-secretstorage
--disable-updates
--disable-telemetry
```

## Recommended settings

```json
{
  "github.gitAuthentication": false,
  "telemetry.telemetryLevel": "off",
  "update.mode": "none",
  "extensions.autoUpdate": false,
  "extensions.autoCheckUpdates": false,
  "workbench.startupEditor": "none"
}
```

## GitHub workflow

Use GitHub CLI instead of VSCode sign-in:

```bash
gh auth login
gh auth setup-git
git pull
git push
```

When VSCode shows the sign-in screen, choose:

```text
Continue without Signing In
```

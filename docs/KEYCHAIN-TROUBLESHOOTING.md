# VSCode Keychain Troubleshooting on macOS

## Symptom

```text
An OS keyring couldn't be identified for storing the encryption related data in your current desktop environment.
```

or:

```text
Keychain lookup ... errKCAuthFailed
```

## Practical fix for this template

Avoid VSCode GitHub sign-in and use GitHub CLI:

```bash
gh auth login
gh auth setup-git
```

Then use:

```bash
git pull
git push
```

## Launcher flags

The launcher includes:

```bash
--password-store=basic
--use-inmemory-secretstorage
```

## If you want to repair macOS Keychain

```bash
killall "Electron" 2>/dev/null || true
killall "Visual Studio Code - Insiders" 2>/dev/null || true
security delete-generic-password -s "Code Safe Storage" ~/Library/Keychains/login.keychain-db 2>/dev/null || true
security delete-generic-password -s "Code - Insiders Safe Storage" ~/Library/Keychains/login.keychain-db 2>/dev/null || true
security delete-generic-password -s "Visual Studio Code - Insiders Safe Storage" ~/Library/Keychains/login.keychain-db 2>/dev/null || true
security unlock-keychain ~/Library/Keychains/login.keychain-db
```

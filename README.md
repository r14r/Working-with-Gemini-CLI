# Local AI VSCode Dev Pipeline

This template configures a Copilot-free AI coding workflow with:

- VSCode isolated user data and extensions
- no VSCode GitHub login requirement
- Ollama for local coding models
- Continue extension for local AI coding inside VSCode
- Gemini CLI for optional cloud/agent-style tasks
- GitHub CLI for GitHub authentication

## Quick start

```bash
chmod +x bin/*
brew install ollama gh
ollama serve
ollama pull qwen2.5-coder:7b
ollama pull llama3.2:3b
ollama pull deepseek-coder:6.7b
gh auth login
gh auth setup-git
cp .gemini/.env.example .gemini/.env
./bin/dev-start  "github.gitAuthentication": false,
  "telemetry.telemetryLevel": "off",
  "extensions.autoUpdate": false,
  "chat.commandCenter.enabled": false,
  "editor.minimap.enabled": false
```

## VSCode keychain strategy

The launcher uses:

```bash
--password-store=basic
--use-inmemory-secretstorage
```

This avoids the macOS keychain path for VSCode secret storage as much as possible. GitHub push/pull should use `gh`, not VSCode login.

## Main commands

```bash
./bin/vscode
./bin/dev-start
./bin/ai "create a FastAPI health endpoint"
cat main.py | ./bin/ai "review this file"
./bin/ai-review
./bin/ai-commit
./bin/gemini-task chat
```

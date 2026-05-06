# Vibe Coding Workflow without Copilot

## Loop

1. Describe the target feature in Continue or `./bin/ai`.
2. Generate or edit code.
3. Run tests.
4. Review the diff with `./bin/ai-review`.
5. Generate a commit message with `./bin/ai-commit`.
6. Commit and push with Git/GitHub CLI.

## Commands

```bash
./bin/ai "create a FastAPI upload endpoint with validation"
./bin/ai-review
git add .
./bin/ai-commit
git commit -m "feat(api): add upload endpoint"
git push
```

## Model routing

| Task | Tool | Model |
|---|---|---|
| Inline edits | Continue | qwen2.5-coder:7b |
| Fast autocomplete | Continue | llama3.2:3b |
| Diff review | ./bin/ai-review | qwen2.5-coder:7b |
| Large planning | Gemini CLI | Gemini |
| Private refactor | Ollama | deepseek-coder:6.7b |

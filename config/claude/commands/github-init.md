---
description: Initialize git repo and push to GitHub
allowed-tools: Bash(git:*), Bash(gh:*), Read, Glob
argument-hint: [repo-name]
---

# Initialize Git Repository and Push to GitHub

## Defaults
- **Repo name**: Use $ARGUMENTS if provided, otherwise use the current directory name
- **Visibility**: Public
- **Commit message**: "Initial commit"
- **Branch**: main

## Steps

1. **Check prerequisites**
   - Verify `gh` CLI is installed and authenticated (`gh auth status`)
   - Verify this is not already a git repository

2. **Determine repo name**
   - If $ARGUMENTS provided, use that
   - Otherwise, use the current folder name (basename of working directory)

3. **Infer description**
   - Check if PRODUCT_SPEC.md exists — if so, read it and extract a one-line project description
   - If no PRODUCT_SPEC.md, check for README.md and infer from there
   - If no docs found, ask the user for a description
   - Present the inferred description to the user for confirmation/editing before proceeding

4. **Initialize and commit**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

5. **Create GitHub repository and push**
   ```bash
   gh repo create <repo-name> --public --source=. --remote=origin --push --description "<description>"
   ```

6. **Display result**
   - Get the SSH URL: `gh repo view --json sshUrl --jq '.sshUrl'`
   - Display success message with the SSH clone URL

## Error Handling
- If already a git repo with commits, ask user if they want to just create remote and push
- If `gh` not authenticated, tell user to run `gh auth login`
- If repo name already exists on GitHub, ask user for alternative name

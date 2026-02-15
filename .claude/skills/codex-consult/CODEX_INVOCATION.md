# Codex CLI Invocation (Consultation)

Detailed instructions for invoking Codex CLI for document consultation.

## Execution Rules (MANDATORY)

1. **NEVER use `run_in_background`** — Always execute Codex synchronously.
   Background execution generates delayed notifications for every attempt,
   creating noise for the user.

2. **NEVER retry with modified syntax** — If the command fails, report the
   exit code and skip. Do NOT try alternative subcommands, flag combinations,
   or workarounds.

3. **Use the EXACT command documented below** — Do not improvise flags,
   rearrange arguments, or substitute subcommands (e.g. do not switch
   from `codex exec` to `codex review`).

## Safety Guard (Prevent Accidental Commits)

Codex runs with `--sandbox danger-full-access` for network access but this also
grants write access to the working tree. The safety guard prevents Codex from
making unintended commits during consultation.

```bash
# Record HEAD before Codex runs
HEAD_BEFORE=$(git rev-parse HEAD)

# Stash uncommitted changes to protect working tree
STASHED=false
if ! git diff --quiet HEAD 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
  git stash push -m "codex-consult-safety-$(date +%s)" --include-untracked
  STASHED=true
fi
```

## Build Command

```bash
# Create output file path
OUTPUT_FILE="/tmp/codex-consult-output-$(date +%s).txt"

# Read config (model selection handled by SKILL.md Step 1)
CONSULT_MODEL=$(jq -r '.codexConsult.researchModel // .codexReview.researchModel // empty' .claude/settings.local.json 2>/dev/null)
TIMEOUT_MINS=$(jq -r '.codexConsult.consultTimeoutMinutes // 15' .claude/settings.local.json 2>/dev/null || echo "15")

# Build model flag if configured
MODEL_FLAG=""
if [ -n "$CONSULT_MODEL" ]; then
  MODEL_FLAG="--model $CONSULT_MODEL"
fi

# Execute (use Bash tool's timeout parameter for timeout — NOT shell `timeout`)
cat {prompt_file} | codex exec \
  --sandbox danger-full-access \
  -c 'approval_policy="never"' \
  -c 'features.search=true' \
  $MODEL_FLAG \
  -o $OUTPUT_FILE \
  -
EXIT_CODE=$?

# --- Post-Invocation Safety Check ---
# Revert any commits Codex may have made
HEAD_AFTER=$(git rev-parse HEAD)
if [ "$HEAD_BEFORE" != "$HEAD_AFTER" ]; then
  echo "WARNING: Codex made commits during consultation. Reverting."
  git reset --hard "$HEAD_BEFORE"
fi

# Restore stashed changes
if [ "$STASHED" = true ]; then
  git stash pop
fi
# --- End Safety Check ---

# Handle exit codes
if [ $EXIT_CODE -eq 124 ]; then
  # Timeout - return partial output if available
  CODEX_STATUS="error"
  CODEX_REASON="Timeout after ${TIMEOUT_MINS} minutes"
elif [ $EXIT_CODE -ne 0 ]; then
  # Error - log and return error status
  CODEX_STATUS="error"
  CODEX_REASON="Codex exited with code $EXIT_CODE"
fi

# Read output
if [ -f "$OUTPUT_FILE" ]; then
  CODEX_OUTPUT=$(cat "$OUTPUT_FILE")
  rm -f "$OUTPUT_FILE"
else
  CODEX_STATUS="error"
  CODEX_REASON="No output file produced"
fi
```

## Flags Explained

| Flag | Purpose |
|------|---------|
| `--sandbox danger-full-access` | Enables network access for documentation research |
| `-c 'approval_policy="never"'` | Non-interactive execution |
| `-c 'features.search=true'` | Enable web search for documentation research |
| `--model` | Optional, use configured model or Codex default |
| `-o $OUTPUT_FILE` | Write final response to file for parsing |
| `-` | Read prompt from stdin |

## Important Notes

**Do NOT use `2>&1`** — Codex streams progress to stderr and final output to stdout. Merging them corrupts the parseable response.

**Timeout:** Use configured timeout (default: 15 minutes). Consultation may need time to research.

## Failure Handling

| Failure | Action |
|---------|--------|
| Codex times out | Return partial output if available |
| Codex errors | Log error, return `status: error` |
| Output is malformed | Attempt best-effort parsing |

## Parse Results

Extract structured findings from Codex output:

```json
{
  "status": "pass | pass_with_notes | needs_attention | error | skipped",
  "issues": [
    {
      "description": "string",
      "location": "string (section name or file reference)",
      "suggestion": "string"
    }
  ],
  "suggestions": [
    {
      "description": "string",
      "location": "string",
      "suggestion": "string"
    }
  ],
  "positive_findings": ["string"],
  "alignment_check": {
    "checked": true | false,
    "items_checked": 0,
    "all_addressed": true | false,
    "missing_items": ["string"]
  },
  "raw_output": "string (full Codex response for debugging)"
}
```

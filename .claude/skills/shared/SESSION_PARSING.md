# Session Parsing Reference

How to read past conversation transcripts from Claude Code and Codex CLI.

## File Locations

### Claude Code
- Path: `~/.claude/projects/<encoded-project-path>/<session-id>.jsonl`
- The `<encoded-project-path>` is the absolute path with `/` replaced by `-` (e.g., `-Users-ben-shoemaker-Projects-myapp`)
- Subagent sessions are in `<session-id>/subagents/agent-<id>.jsonl` — skip these unless specifically requested
- Each file is append-only JSONL (one JSON object per line)

### Codex CLI
- Path: `~/.codex/sessions/<year>/<month>/<day>/rollout-<timestamp>-<session-id>.jsonl`
- Same JSONL format but different event structure

## Claude Code JSONL Format

Each line has a `type` field. The content-bearing types are:

### `type: "user"`
```json
{"type": "user", "message": {"role": "user", "content": "..."}, "timestamp": "...", "cwd": "...", "sessionId": "..."}
```
- `message.content` is either a plain string (user's prompt) or a list of content blocks
- Content blocks: `{"type": "text", "text": "..."}` or `{"type": "tool_result", ...}`
- **Skip** messages where content starts with `<system_instruction>`, `<system-reminder>`, `<local-command-caveat>`, `<command-name>`, `<task-notification>`, or `<permissions`

### `type: "assistant"`
```json
{"type": "assistant", "message": {"role": "assistant", "content": [...]}, "costUSD": ...}
```
- `message.content` is a list of blocks:
  - `{"type": "text", "text": "..."}` — assistant's response text
  - `{"type": "tool_use", "name": "...", "input": {...}}` — tool invocation
  - `{"type": "thinking", "text": "..."}` — extended thinking (usually not relevant for search)

### Metadata-only types (skip for content)
- `permission-mode`, `file-history-snapshot`, `queue-operation`, `last-prompt`, `system`, `attachment`

## Codex CLI JSONL Format

Each line has a `type` field. The wrapper structure differs from Claude Code.

### `type: "session_meta"`
```json
{"type": "session_meta", "payload": {"id": "...", "cwd": "...", "model": "..."}}
```

### `type: "response_item"`
```json
{"type": "response_item", "payload": {"role": "user"|"assistant"|"developer", "content": [...]}}
```
- `role: "user"` — content blocks with `{"type": "input_text", "text": "..."}`
- `role: "assistant"` — content blocks with `{"type": "output_text", "text": "..."}`
- `role: "developer"` — system/developer instructions (skip for content search)
- **Skip** blocks where text starts with `<permissions`, `<collaboration_mode>`, `<personality_spec>`, or `# AGENTS.md`

### `type: "event_msg"` / `type: "turn_context"`
- Metadata events — skip for content search

## Extracting Session Metadata

### Claude Code
- **Project path**: decode the directory name (replace leading `-` with `/`, then `-` with `/` for path segments)
- **Session ID**: the JSONL filename without extension
- **Date**: from `timestamp` field on first `user` event, or file modification time
- **Git branch**: from `gitBranch` field on events

### Codex CLI
- **Project path**: from `session_meta.payload.cwd`
- **Session ID**: from `session_meta.payload.id`
- **Date**: from filename timestamp or `session_meta.payload.timestamp`
- **Model**: from `turn_context.payload.model`

## Practical Notes

- Session files can be large (500KB+). For search, read line-by-line and skip non-content types early.
- For recent sessions, sort by file modification time (`stat -f "%m" on macOS`).
- To find sessions for a specific project, match on the encoded project path in the directory name.
- User messages with `<local-command-stdout>` contain command output the user ran — these can be useful context but are not user-authored text.

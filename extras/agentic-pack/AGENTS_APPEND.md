## Conversation-First Agent Workflow

- Default to conversation-first for medium/large work: ask for options and tradeoffs before editing.
- Estimate blast radius before changes: expected files, risks, and verification plan.
- Interrupt long runs if progress stalls; ask for status and choose continue, redirect, or abort.
- Keep commits atomic and path-scoped. Never mix unrelated changes in one commit.
- After each feature or bug fix, add or update tests in the same context unless the change is purely visual.
- For UI work, prefer screenshot + short instruction over long prose when possible.
- Keep docs current in `docs/` and scan docs first (for example `rg --files docs`) before coding in unfamiliar areas.
- Escalate stuck tasks to a stronger model/reviewer with bundled context instead of retrying blindly.

---
name: discover-flow-verification
description: >
  Guide discovery and discussion to determine how an AI coding agent can
  autonomously run and verify a specific user flow end to end. Use when the
  user asks what would be needed to test a flow, prove an app works, create an
  E2E/self-test harness, make agent verification repeatable, or evaluate
  whether an existing test setup lets the agent verify behavior. This skill is
  for shaping the verification approach before implementation: read the repo's
  product docs and existing verification contracts, identify the real user flow
  and channel under test, uncover missing controllable state or external
  dependencies, ask focused questions, and produce a concrete agent-runnable
  verification plan only after the flow is understood.
---

# Discover Flow Verification

## Goal

Reach a shared answer to: **what would an AI coding agent need in order to run this user flow itself and know whether it worked?**

Stay in discovery mode unless the user explicitly asks to implement the harness. The output should be a concrete verification plan, not a generic E2E checklist.

## Operating Mode

- Start from the product goal and the specific flow the user cares about.
- Read the repo's current docs, plans, tests, scripts, and existing verification conventions before proposing a harness shape.
- Ask one focused question at a time when the flow, success condition, or external dependency policy is unclear.
- Prefer the repo's native verification surface over a new command if it already fits.
- Treat harness patterns as options, not requirements. Do not assume browser, screenshots, services, temp apps, seeded DBs, MCP, OAuth, or external sandboxes are needed until the flow demands them.

## Discovery Steps

### 1. Name The Flow

Write the candidate flow in plain user language:

```text
A <user/integration/agent> can <action sequence>, and then <observable product outcome> is true.
```

If the flow is too broad, narrow it to the first valuable slice the agent should be able to verify.

### 2. Identify The Channel Under Test

Decide which channel must actually work for the claim to be true:

- Browser UI
- CLI
- HTTP API
- SDK/runtime import
- MCP or agent client
- Desktop app
- Mobile app
- Worker/job queue
- Webhook/provider callback
- Local file/archive import
- Database-backed read path

Do not substitute an easier adjacent channel. For example, if the product claim is "developers integrate through MCP," the verification must drive an MCP client. If the claim is "CLI retrieves imported messages," the verification must spawn the CLI and inspect its output.

### 3. Map The Agent's Blind Spots

List what the agent currently cannot prove unaided:

- Authentication or authorization
- Missing seeded data
- Human-only external account setup
- Provider sandbox or test account state
- Local service startup
- Long-running background jobs
- Async ingestion or eventual consistency
- UI state that needs browser evidence
- Private user data that cannot be used in tests
- Outputs that are only visible in logs, files, DB rows, or third-party dashboards

This list usually determines the harness design.

### 4. Choose Controllable State

For each required state source, decide how the agent can control it:

- Use fixture files, fixture DBs, fake servers, local event sinks, temp data dirs, or generated target apps.
- Use sandbox-owned external resources when real provider behavior matters.
- Use local test auth or private test credentials when auth is part of the flow.
- Stop and document exact manual setup if a dependency cannot be safely automated.

The target is not perfect realism. The target is enough realism that the agent can catch the failures that matter for this flow.

### 5. Define Success And Failure

Define what the agent must assert from outside the implementation:

- Command output and exit code
- Browser-visible state
- API response
- Imported records
- Retrieved messages or evidence snippets
- Dashboard metrics
- Generated files
- Job status
- Logs
- Provider sandbox state

Include negative assertions when they matter, such as no duplicate imports, no leaked secrets, no human account use, or no stale state after rerun.

### 6. Decide Repeatability

Explain how the verification can be torn down and recreated repeatedly:

- What gets created each run?
- What gets reused?
- What must be cleaned even after failure?
- What artifacts should survive for debugging?
- What makes reruns idempotent?

If repeatability is not possible yet, name the blocker and the smallest prerequisite feature.

## Plan Output

When the discussion has enough information, produce a concise plan with:

- **Flow claim:** the exact behavior being verified.
- **Channel under test:** the real entry point the harness must drive.
- **Harness shape:** existing test, new script, CLI integration test, browser flow, fake provider, sandbox flow, or combination.
- **Setup/state:** fixtures, temp dirs, seeded DBs, auth, external dependencies.
- **Driver:** the command/browser/API/client actions the agent runs.
- **Assertions:** what proves success and what proves important failure modes are absent.
- **Evidence:** logs, JSON output, screenshots, traces, DB snapshots, provider records, or artifacts to keep.
- **Teardown/rerun:** how state is cleaned and how the agent reruns it.
- **Open decisions:** only the unresolved choices that block implementation.

Do not include implementation tasks until the user asks to build it.

## Quality Bar

A good result lets a future AI coding agent say:

```text
I can run <exact command or steps>, observe <evidence>, and decide pass/fail for <specific flow> without using a human's private state or asking for manual interpretation.
```

If the plan does not reach that bar, continue discovery instead of pretending the harness is defined.

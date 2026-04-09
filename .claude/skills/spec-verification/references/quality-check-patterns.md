# Quality Check Pattern Tables

## PRODUCT_SPEC.md / FEATURE_SPEC.md Quality Checks

| ID | Check | Pattern to Detect | Severity |
|----|-------|-------------------|----------|
| Q-PS-001 | Missing User Flow | Feature mentioned without step-by-step interaction | MAJOR |
| Q-PS-002 | Undefined Edge Cases | Only happy path described | MAJOR |
| Q-PS-003 | Unbounded Scope | "all", "any", "every" without limits | CRITICAL |
| Q-PS-004 | Missing Non-Functional | No mention of performance, security, or accessibility | MAJOR |

## TECHNICAL_SPEC.md / FEATURE_TECHNICAL_SPEC.md Quality Checks

| ID | Check | Pattern to Detect | Severity |
|----|-------|-------------------|----------|
| Q-TS-001 | Architecture Without Justification | Pattern chosen without tradeoff discussion | MAJOR |
| Q-TS-002 | Incomplete Data Model | Entity without fields, types, or constraints | CRITICAL |
| Q-TS-003 | Undefined API Contract | Endpoint without request/response shape | CRITICAL |
| Q-TS-004 | Orphaned Dependency | External service mentioned but never integrated | MAJOR |
| Q-TS-005 | Implementation Detail | Code snippets or specific implementation in spec | MINOR |

## EXECUTION_PLAN.md Quality Checks

| ID | Check | Pattern to Detect | Severity |
|----|-------|-------------------|----------|
| Q-EP-001 | Untestable Acceptance Criteria | Criterion that can't be verified programmatically | CRITICAL |
| Q-EP-002 | Missing Task Dependency | Task references another task's output without declared dependency | CRITICAL |
| Q-EP-003 | Circular Dependency | A depends on B depends on C depends on A | CRITICAL |
| Q-EP-004 | Orphaned Spec Reference | Task references spec section that doesn't exist | CRITICAL |
| Q-EP-005 | Insufficient Criteria | Task has fewer than 3 acceptance criteria | MAJOR |
| Q-EP-006 | Oversized Task | Task description suggests >1 day of work | MAJOR |
| Q-EP-007 | Vague Acceptance Criterion | Uses "should", "properly", "correctly" without specifics | CRITICAL |
| Q-EP-008 | Missing Verification Metadata | Acceptance criterion missing verification type or method | CRITICAL |

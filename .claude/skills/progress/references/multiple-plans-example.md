# Multiple Plans Output Example

```
OVERALL PROJECT PROGRESS
========================

  Plan                              Status        Progress
  ---------------------------------------------------------
  Main Project                      Complete      45/45 (100%)
  Feature: user-auth                In Progress   12/18 (67%)
  Feature: payments                 Not Started    0/24 (0%)
  ---------------------------------------------------------
  TOTAL                                           57/87 (66%)

---------------------------------------------------------

MAIN PROJECT (Complete)
=======================
All 4 phases complete. 45/45 task criteria satisfied.

---------------------------------------------------------

FEATURE: user-auth (In Progress)
================================
Location: features/user-auth/EXECUTION_PLAN.md

| Phase | Status | Task Criteria | Checkpoint |
|-------|--------|---------------|------------|
| Phase 1: OAuth Setup | Complete | 6/6 (100%) | 2/2 |
| Phase 2: Session Mgmt | In Progress | 6/12 (50%) | 0/3 |

Current: Task 2.1.B - Add session refresh logic
Next: Complete Task 2.1.B, then Task 2.1.C

---------------------------------------------------------

FEATURE: payments (Not Started)
===============================
Location: features/payments/EXECUTION_PLAN.md

| Phase | Status | Task Criteria | Checkpoint |
|-------|--------|---------------|------------|
| Phase 1: Stripe Setup | Not Started | 0/8 (0%) | 0/2 |
| Phase 2: Checkout | Not Started | 0/10 (0%) | 0/3 |
| Phase 3: Webhooks | Not Started | 0/6 (0%) | 0/2 |

---------------------------------------------------------

NEXT ACTION
===========
Continue with Feature: user-auth
  cd features/user-auth
  /phase-start 2  (or continue Task 2.1.B)
```

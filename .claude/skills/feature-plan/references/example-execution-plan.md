# Example: Adding User Notifications Feature

Here's a condensed example of how a feature execution plan might look:

```markdown
# Execution Plan: User Notifications

## Overview
| Metric | Value |
|--------|-------|
| Feature | Real-time user notifications |
| Target Project | MyApp |
| Total Phases | 3 |
| Total Steps | 7 |
| Total Tasks | 15 |

## Integration Points
| Existing Component | Integration Type | Notes |
|--------------------|------------------|-------|
| `src/lib/api.ts` | extends | Add notification endpoints |
| `src/hooks/useAuth.ts` | uses | Get current user for subscriptions |
| `src/components/Layout.tsx` | modifies | Add notification bell to header |
| `src/lib/db/schema.ts` | extends | Add notifications table |

## Phase Dependency Graph
+-----------------+
| Phase 1:        |
| Data Layer      |
+--------+--------+
         |
         v
+-----------------+
| Phase 2:        |
| API & Backend   |
+--------+--------+
         |
         v
+-----------------+
| Phase 3:        |
| UI & Real-time  |
+-----------------+

---

## Phase 1: Data Layer

**Goal:** Establish database schema and data access patterns for notifications
**Depends On:** None

### Pre-Phase Setup
- [ ] Confirm database migration tooling is working
  - Verify: `{migration command} --help`
- [ ] Review existing schema patterns in `src/lib/db/`
  - Verify: `rg "CREATE TABLE users" src/lib/db/migrations/001_users.sql`

### Step 1.1: Schema & Migrations

#### Task 1.1.A: Create Notifications Table

**Description:**
Add a notifications table following existing schema patterns. This table stores
user notifications with support for read/unread status and different notification types.

**Acceptance Criteria:**
- [ ] (CODE) Migration creates `notifications` table with columns: id, user_id, type, title, body, read, created_at
  - Verify: `src/lib/db/migrations/003_notifications.sql` includes column definitions
- [ ] (CODE) Foreign key constraint links to existing users table
  - Verify: migration file includes `FOREIGN KEY (user_id) REFERENCES users(id)`
- [ ] (CODE) Index exists on user_id + created_at for efficient queries
  - Verify: migration file includes `CREATE INDEX` on `(user_id, created_at)`
- [ ] (TEST) Migration runs successfully (up and down)
  - Verify: test `should run migrations up and down`

**Files to Create:**
- `src/lib/db/migrations/003_notifications.sql` -- migration file

**Files to Modify:**
- `src/lib/db/schema.ts` -- add Notification type

**Existing Code to Reference:**
- `src/lib/db/migrations/001_users.sql` -- follow migration patterns
- `src/lib/db/schema.ts` -- follow type definition patterns

**Dependencies:** None

**Spec Reference:** Feature Spec > Data Model

**Browser Verification:**
- Criteria IDs: None
- Notes: N/A

...
```

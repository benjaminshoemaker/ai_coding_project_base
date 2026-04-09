# Tech Debt Check Example Output

Given a TypeScript project:

```
$ /tech-debt-check

TECHNICAL DEBT REPORT
=====================
Project: my-api
Analyzed: 2025-01-10 14:30:00
Files scanned: 45

SUMMARY
-------
Overall Health: WARNING
Tech Debt Score: 34/100

DUPLICATION (WARNING)
----------------------
Duplicate code: 8 blocks, 4.2% of codebase

Largest duplicates:
1. src/api/users.ts:45-60 <-> src/api/posts.ts:32-47 (15 lines)
   -> Both validate request body identically

Action: Extract to src/middleware/validateBody.ts

COMPLEXITY (GOOD)
-----------------
Average complexity: 4.2
No functions exceed threshold.

FILE SIZE (WARNING)
-------------------
Large files:
1. src/services/auth.ts -- 342 lines

Action: Split token management into separate module

AI CODE SMELLS (GOOD)
---------------------
No significant issues detected.

RECOMMENDATIONS
---------------
Priority fixes:
1. Extract duplicate validation logic (saves 30 lines)
2. Split auth.ts into auth.ts + tokens.ts

Status: PASSED WITH NOTES
```

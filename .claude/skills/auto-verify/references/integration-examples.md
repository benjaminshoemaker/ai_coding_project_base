# Auto-Verify Integration Examples

## Example 1: API Endpoint Verification

**Input:**
```
Criterion: "POST /api/users returns 201 with user object"
Verify: POST /api/users with body {"name": "test"}
```

**Processing:**
1. Pattern detected: `API`, `returns`, `201` -> curl pattern
2. Tool: curl (always available)
3. Command: `curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d '{"name":"test"}' http://localhost:3000/api/users`
4. Execute: Returns "201"
5. Result: PASS

**Output:**
```
AUTO-VERIFY RESULT
------------------
Criterion: "POST /api/users returns 201 with user object"
Pattern Detected: API status code
Tool Used: curl
Command: curl -s -o /dev/null -w "%{http_code}" -X POST ...
Status: PASS
Duration: 234ms
Output: 201
```

## Example 2: Page Load Check

**Input:**
```
Criterion: "Dashboard page loads at /dashboard"
```

**Processing:**
1. Pattern detected: `page loads` -> curl first (HTTP status sufficient)
2. Tool: curl
3. Command: `curl -sf http://localhost:3000/dashboard -o /dev/null`
4. Execute: Success (exit code 0)
5. Result: PASS (no browser needed)

**Output:**
```
AUTO-VERIFY RESULT
------------------
Criterion: "Dashboard page loads at /dashboard"
Pattern Detected: page accessibility
Tool Used: curl (HTTP-first)
Command: curl -sf http://localhost:3000/dashboard -o /dev/null
Status: PASS
Duration: 156ms
Output: HTTP 200 OK
```

## Example 3: Truly Manual Criterion

**Input:**
```
Criterion: "Copy matches brand tone and feels professional"
```

**Processing:**
1. Pattern detected: `feels`, `brand`, `tone` -> truly manual
2. Tool: none
3. Result: MANUAL

**Output:**
```
AUTO-VERIFY RESULT
------------------
Criterion: "Copy matches brand tone and feels professional"
Pattern Detected: subjective judgment
Tool Used: none
Command: N/A
Status: MANUAL
Duration: 0ms
Output: N/A
Reason: Subjective criteria requiring human judgment (brand tone, professional feel)
```

## Example 4: Failed Automation

**Input:**
```
Criterion: "API returns list of users"
```

**Processing:**
1. Pattern detected: `API`, `returns` -> curl pattern
2. Tool: curl
3. Command: `curl -sf http://localhost:3000/api/users`
4. Execute: Connection refused
5. Result: FAIL

**Output:**
```
AUTO-VERIFY RESULT
------------------
Criterion: "API returns list of users"
Pattern Detected: API response
Tool Used: curl
Command: curl -sf http://localhost:3000/api/users
Status: FAIL
Duration: 5012ms
Output: curl: (7) Failed to connect to localhost port 3000: Connection refused
Suggested Fix: Start the dev server with `npm run dev` or check if port 3000 is correct
```

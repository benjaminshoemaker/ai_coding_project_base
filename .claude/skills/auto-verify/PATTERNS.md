# Auto-Verify Patterns Reference

Single source of truth for what CAN vs CANNOT be automated.
Referenced by: `/feature-plan`, `/generate-plan`, `/criteria-audit`, `/auto-verify`.

## MANUAL Decision Tree

Walk through this BEFORE tagging any acceptance criterion as MANUAL:

1. Can it be verified by checking if a file/directory exists? → **(CODE)** `Verify: test -f {path}`
2. Can it be verified by checking if a file contains specific text/exports? → **(CODE)** `Verify: grep -q {pattern} {path}`
3. Can it be verified by running a test? → **(TEST)** `Verify: {test name}`
4. Can it be verified by hitting an API endpoint? → **(CODE)** `Verify: curl -sf {url}`
5. Can it be verified by checking if a page loads (HTTP 200)? → **(CODE)** `Verify: curl -sf {url}`
6. Can it be verified by checking DOM elements or visible text? → **(BROWSER:DOM)** `Verify: route + selector`
7. Can it be verified by checking browser console for errors? → **(BROWSER:CONSOLE)** `Verify: route`
8. Can it be verified by checking an environment variable? → **(CODE)** `Verify: test -n "$VAR"`
9. Does it require subjective human judgment?
   → 9a. Does the NEXT phase depend on this judgment? → **(MANUAL)** with `Reason:`
   → 9b. No downstream dependency? → **(MANUAL:DEFER)** with `Reason:`

**If you reach step 9, it is truly manual. Otherwise, use the automated type.**
Choose 9a (blocking) or 9b (deferrable) based on whether downstream work depends on this judgment. See "Manual Subtypes" below.

Most tasks should have **ZERO** manual criteria. Maximum 1-2 per task.
MANUAL criteria exceeding 10% of total in a plan is a red flag.

## Pattern Matching Table

| Priority | Pattern Keywords | Tool | Command Template |
|----------|-----------------|------|------------------|
| 1 | `curl`, `endpoint`, `API`, `/api/`, `returns`, `status code`, `HTTP` | curl | Status/response check |
| 2 | `response contains`, `JSON contains`, `body includes` | curl+jq/grep | Content verification |
| 3 | `redirect`, `redirects to`, `Location header`, `302`, `301` | curl | Header inspection |
| 4 | `health`, `running`, `reachable`, `alive`, `up`, `accessible` | curl | Health check |
| 5 | `page loads`, `loads at`, `visit`, `navigate to` | curl first | HTTP status (skip browser if sufficient) |
| 6 | `visible`, `shows`, `displays`, `element`, `selector`, `DOM` | browser | Browser snapshot required |
| 7 | `console`, `no errors`, `warnings`, `logs` | browser | Console inspection |
| 8 | `file exists`, `created`, `generated`, `written` | bash | File existence check |
| 9 | `directory exists`, `folder`, `path` | bash | Directory check |
| 10 | `env var`, `environment variable`, `\$`, `set` | bash | Environment check |
| 11 | `looks`, `feels`, `UX`, `intuitive`, `user experience`, `brand`, `tone` | NONE | Truly manual |

## Command Generation Templates

### HTTP Patterns (curl-based)

**Status Check:**
```bash
# Check if endpoint returns success (2xx/3xx)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "{url}")
[ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 400 ] && echo "PASS:status_$HTTP_CODE" || echo "FAIL:status_$HTTP_CODE"
```

**Response Contains Text:**
```bash
# Check if response body contains expected text
curl -s "{url}" | grep -q "{expected_text}" && echo "PASS:text_found" || echo "FAIL:text_missing"
```

**JSON Field Exists:**
```bash
# Check if JSON response has expected field
curl -s "{url}" | jq -e '.{json_path}' > /dev/null 2>&1 && echo "PASS:field_exists" || echo "FAIL:field_missing"
```

**Redirect Check:**
```bash
# Check if redirect goes to expected location
curl -sI "{url}" | grep -i "location:" | grep -qi "{expected_location}" && echo "PASS:redirect_ok" || echo "FAIL:redirect_wrong"
```

**Health Check:**
```bash
# Check service health (try /health first, then root)
curl -sf "{url}/health" -o /dev/null 2>/dev/null || curl -sf "{url}" -o /dev/null && echo "PASS:service_healthy" || echo "FAIL:service_unreachable"
```

### File Patterns (bash-based)

**File Exists:**
```bash
test -f "{path}" && echo "PASS:file_exists" || echo "FAIL:file_missing"
```

**File Contains:**
```bash
grep -q "{pattern}" "{path}" && echo "PASS:content_found" || echo "FAIL:content_missing"
```

**Directory Exists:**
```bash
test -d "{path}" && echo "PASS:dir_exists" || echo "FAIL:dir_missing"
```

### Environment Patterns (bash-based)

**Environment Variable Set:**
```bash
test -n "${VAR_NAME}" && echo "PASS:env_set" || echo "FAIL:env_missing"
```

## Manual Subtypes: BLOCKING vs DEFER

After the decision tree reaches step 9 (truly manual), classify the subtype:

| Subtype | Tag | When to use | Example |
|---------|-----|-------------|---------|
| Blocking | (MANUAL) | Next phase depends on this judgment | "Data model correctly represents domain" |
| Deferrable | (MANUAL:DEFER) | No downstream dependency; purely cosmetic/tonal | "Button color matches brand palette" |

Default: If unsure, use (MANUAL). It's safer to block than to defer something critical.

## Truly Manual Patterns

These patterns indicate criteria that genuinely require human judgment:

| Pattern | Reason |
|---------|--------|
| `looks`, `appears`, `visual` | Subjective visual assessment |
| `feels`, `intuitive`, `UX` | User experience judgment |
| `brand`, `tone`, `voice` | Brand consistency |
| `professional`, `polished` | Quality perception |
| `easy to use`, `user-friendly` | Usability judgment |
| `appropriate`, `suitable` | Context-dependent evaluation |
| `creative`, `engaging` | Subjective content quality |

## URL and Path Extraction

### URL Extraction Patterns

```
# Look for explicit URLs (use as-is, don't prepend BASE_URL)
/https?:\/\/[^\s]+/

# Look for route patterns (prepend BASE_URL)
/(?:at|to|from)\s+\/[a-zA-Z0-9\/_-]+/

# Look for localhost patterns
/localhost:\d+[^\s]*/
```

### Path Extraction Patterns

```
# Look for file paths
/(?:file|path|in)\s+[a-zA-Z0-9\/_.-]+/

# Look for common patterns
/src\/[^\s]+/
/\.\/[^\s]+/
```

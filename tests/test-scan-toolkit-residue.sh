#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temp_root="$(mktemp -d)"
trap 'rm -rf "$temp_root"' EXIT

fixture="$temp_root/project"
canonical="$temp_root/canonical"
mkdir -p "$fixture/.claude/skills/phase-start"
mkdir -p "$fixture/.claude/skills/ui-ux"
mkdir -p "$fixture/.claude/skills.bak/migrate-global/phase-start"
mkdir -p "$fixture/.claude/verification"
mkdir -p "$canonical/ui-ux"
mkdir -p "$fixture/plans/greenfield"
mkdir -p "$fixture/features/analytics_coverage_map"
mkdir -p "$fixture/src"

touch "$fixture/.toolkit-marker"
touch "$fixture/.claude/skills/phase-start/SKILL.md"
touch "$fixture/.claude/skills/ui-ux/SKILL.md"
touch "$fixture/.claude/skills.bak/migrate-global/phase-start/SKILL.md"
touch "$fixture/.claude/verification/phase-1.md"
touch "$fixture/.claude/verification-log.jsonl"
touch "$canonical/ui-ux/SKILL.md"
touch "$fixture/plans/greenfield/PRODUCT_SPEC.md"
touch "$fixture/features/analytics_coverage_map/FEATURE_BRIEF.md"
touch "$fixture/NEXT_FEATURES.md"
touch "$fixture/NEXT_STEPS.md"
touch "$fixture/DEFERRED.md"
touch "$fixture/BUGS.md"
touch "$fixture/LEARNINGS.md"
touch "$fixture/src/app.ts"
printf '%s\n' '# Instructions' 'Run /phase-start after /phase-prep.' >"$fixture/AGENTS.md"

before="$temp_root/before.txt"
after="$temp_root/after.txt"
output="$temp_root/output.txt"

find "$fixture" -type f -print | sort >"$before"
"$repo_root/scripts/scan-toolkit-residue.sh" "$fixture" >"$output"
find "$fixture" -type f -print | sort >"$after"

diff -u "$before" "$after"
grep -F $'HIGH\t.toolkit-marker\t' "$output" >/dev/null
grep -F $'HIGH\t.claude/skills/phase-start\t' "$output" >/dev/null
grep -F $'MEDIUM\t.claude/skills/ui-ux\t' "$output" >/dev/null
grep -F $'HIGH\t.claude/skills.bak\t' "$output" >/dev/null
grep -F $'HIGH\t.claude/verification\t' "$output" >/dev/null
grep -F $'HIGH\t.claude/verification-log.jsonl\t' "$output" >/dev/null
grep -F $'REVIEW\tplans/greenfield/PRODUCT_SPEC.md\t' "$output" >/dev/null
grep -F $'REVIEW\tfeatures/analytics_coverage_map\t' "$output" >/dev/null
grep -F $'REVIEW\tNEXT_FEATURES.md\t' "$output" >/dev/null
grep -F $'REVIEW\tNEXT_STEPS.md\t' "$output" >/dev/null
grep -F $'REVIEW\tDEFERRED.md\t' "$output" >/dev/null
grep -F $'REVIEW\tBUGS.md\t' "$output" >/dev/null
grep -F $'REVIEW\tLEARNINGS.md\t' "$output" >/dev/null
grep -F $'REVIEW\tAGENTS.md\t' "$output" >/dev/null

canonical_output="$temp_root/canonical-output.txt"
"$repo_root/scripts/scan-toolkit-residue.sh" \
  --canonical-skills "$canonical" "$fixture" >"$canonical_output"
grep -F $'MEDIUM\t.claude/skills/ui-ux\tMatches canonical skill; prefer selective global installation' \
  "$canonical_output" >/dev/null

printf '%s\n' 'local customization' >>"$fixture/.claude/skills/ui-ux/SKILL.md"
"$repo_root/scripts/scan-toolkit-residue.sh" \
  --canonical-skills "$canonical" "$fixture" >"$canonical_output"
grep -F $'REVIEW\t.claude/skills/ui-ux\tDiffers from canonical skill; inspect local modifications before cleanup' \
  "$canonical_output" >/dev/null

if grep -F 'src/app.ts' "$output" >/dev/null; then
  echo "FAIL: ordinary source file was reported" >&2
  exit 1
fi

if "$repo_root/scripts/scan-toolkit-residue.sh" "$temp_root/missing" \
  >"$temp_root/missing.out" 2>"$temp_root/missing.err"; then
  echo "FAIL: missing target unexpectedly succeeded" >&2
  exit 1
fi
grep -F 'Target directory not found' "$temp_root/missing.err" >/dev/null

echo "PASS: toolkit residue scanner"

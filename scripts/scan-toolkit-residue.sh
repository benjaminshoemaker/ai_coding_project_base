#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Scan a project for files likely left by the AI Coding Project Toolkit.

Usage:
  scan-toolkit-residue.sh [--canonical-skills <skills-directory>] <target-directory>

The scanner is read-only. It prints tab-separated findings:
  confidence<TAB>relative-path<TAB>reason

Confidence levels:
  HIGH    Strong toolkit marker or retired generic workflow component.
  MEDIUM  Reusable toolkit skill that may be installed globally instead.
  REVIEW  Document may contain valuable project-specific context.

When --canonical-skills is provided, reusable local skills are compared with
that library. Divergent copies are reported as REVIEW findings.
USAGE
}

canonical_skills=""
target_input=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --canonical-skills)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --canonical-skills" >&2
        exit 2
      fi
      canonical_skills="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -* )
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -n "$target_input" ]]; then
        echo "Only one target directory may be scanned." >&2
        exit 2
      fi
      target_input="$1"
      shift
      ;;
  esac
done

if [[ -z "$target_input" ]]; then
  usage >&2
  exit 2
fi

if [[ ! -d "$target_input" ]]; then
  echo "Target directory not found: $target_input" >&2
  exit 2
fi

if [[ -n "$canonical_skills" && ! -d "$canonical_skills" ]]; then
  echo "Canonical skills directory not found: $canonical_skills" >&2
  exit 2
fi

target_root="$(cd "$target_input" && pwd)"

report() {
  printf '%s\t%s\t%s\n' "$1" "$2" "$3"
}

relative_path() {
  local absolute_path="$1"
  printf '%s' "${absolute_path#"$target_root"/}"
}

printf 'CONFIDENCE\tPATH\tREASON\n'

for marker in \
  .toolkit-marker \
  .claude/toolkit-version.json \
  .claude/verification-config.json \
  .claude/verification-log.jsonl \
  .claude/sync-log.txt \
  .claude/doc-update-pending.json; do
  if [[ -e "$target_root/$marker" || -L "$target_root/$marker" ]]; then
    report "HIGH" "$marker" "Toolkit metadata or transient workflow state"
  fi
done

if [[ -d "$target_root/.workstream" ]]; then
  report "HIGH" ".workstream" "Generic toolkit orchestration infrastructure"
fi

if [[ -d "$target_root/.claude/skills.bak" ]]; then
  report "HIGH" ".claude/skills.bak" "Backup of copied toolkit skills; inspect Git history before cleanup"
fi

if [[ -d "$target_root/.claude/verification" ]]; then
  report "HIGH" ".claude/verification" "Generated toolkit phase-verification reports"
fi

if [[ -d "$target_root/.claude/skills" ]]; then
  for skill_dir in "$target_root/.claude/skills"/*; do
    [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]] || continue
    skill_name="${skill_dir##*/}"
    case "$skill_name" in
      criteria-audit|discover|feature-plan|feature-spec|feature-technical-spec|fresh-start|generate-plan|go|phase-checkpoint|phase-prep|phase-start|populate-state|product-spec|progress|review-deferred|setup|spec-verification|technical-spec|update-target-projects|verify-task)
        report "HIGH" ".claude/skills/$skill_name" "Skill operates the retired specification or phase workflow"
        ;;
      analyze-sessions|audit-agentsmd|audit-skills|auto-verify|browser-verification|capture-learning|capture-session|capture-work|code-verification|codex-consult|codex-implement|codex-review|configure-verification|create-pr|data-flow-audit|discover-flow-verification|feature-audit|innovate|merge-prs|modify-skill|oauth-login|prepare-goal-harness|search-chats|security-scan|suggest-skills|tech-debt-check|tone-check|triage|ui-ux|update-docs|vercel-preview|vision-audit|work-status)
        if [[ -n "$canonical_skills" && -d "$canonical_skills/$skill_name" ]]; then
          if diff -qr "$skill_dir" "$canonical_skills/$skill_name" >/dev/null; then
            report "MEDIUM" ".claude/skills/$skill_name" "Matches canonical skill; prefer selective global installation"
          else
            report "REVIEW" ".claude/skills/$skill_name" "Differs from canonical skill; inspect local modifications before cleanup"
          fi
        else
          report "MEDIUM" ".claude/skills/$skill_name" "Known reusable skill; compare with the canonical global copy before removing"
        fi
        ;;
    esac
  done
fi

if [[ -d "$target_root/.claude/commands" ]]; then
  for command_file in "$target_root/.claude/commands"/*.md; do
    [[ -f "$command_file" ]] || continue
    command_name="${command_file##*/}"
    case "$command_name" in
      generate-plan.md|install-hooks.md|product-spec.md|run-todos.md|sync.md|technical-spec.md|verify-spec.md)
        report "HIGH" ".claude/commands/$command_name" "Legacy toolkit command or workflow shim"
        ;;
    esac
  done
fi

for prompt_file in \
  AGENTS_TEMPLATE.md \
  GENERATOR_PROMPT.md \
  PLAN_ITERATION_PROMPT.md \
  PRODUCT_SPEC_PROMPT.md \
  START_PROMPTS.md \
  TECHNICAL_SPEC_PROMPT.md; do
  if [[ -f "$target_root/$prompt_file" ]]; then
    report "HIGH" "$prompt_file" "Root template for the retired generated workflow"
  fi
done

while IFS= read -r -d '' plan_file; do
  plan_relative="$(relative_path "$plan_file")"
  report "REVIEW" "$plan_relative" "Generated-plan filename; preserve project-specific decisions before cleanup"
done < <(
  find "$target_root" \
    \( -path "$target_root/.git" -o -path "$target_root/node_modules" \) -prune -o \
    -type f \
    \( -name PLAN_STATUS.md -o -name PRODUCT_SPEC.md -o \
       -name TECHNICAL_SPEC.md -o -name EXECUTION_PLAN.md -o \
       -name phase-state.json \) \
    -print0
)

if [[ -d "$target_root/features" ]]; then
  for feature_dir in "$target_root/features"/*; do
    [[ -d "$feature_dir" ]] || continue
    feature_name="${feature_dir##*/}"
    [[ "$feature_name" != "archive" ]] || continue

    if [[ -f "$feature_dir/FEATURE_BRIEF.md" || \
          -f "$feature_dir/FEATURE_SPEC.md" || \
          -f "$feature_dir/FEATURE_TECHNICAL_SPEC.md" || \
          -f "$feature_dir/TECHNICAL_SPEC.md" || \
          -f "$feature_dir/DISCOVERY_NOTES.md" || \
          -f "$feature_dir/EXECUTION_PLAN.md" ]]; then
      report "REVIEW" "features/$feature_name" "Feature folder may contain an unresolved idea or useful design context; determine status before cleanup"
    fi
  done
fi

for context_file in NEXT_FEATURES.md NEXT_STEPS.md DEFERRED.md BUGS.md \
  LEARNINGS.md TODOS.md IDEAS.md ROADMAP.md; do
  if [[ -f "$target_root/$context_file" ]]; then
    report "REVIEW" "$context_file" "May contain unresolved ideas or durable project context; extract before cleanup"
  fi
done

for instruction_file in AGENTS.md CLAUDE.md; do
  instruction_path="$target_root/$instruction_file"
  if [[ -f "$instruction_path" ]] && \
    grep -Eq '(/phase-(start|prep|checkpoint)|plans/PLAN_STATUS\.md|AI Coding (Project )?Toolkit|/generate-plan)' "$instruction_path"; then
    report "REVIEW" "$instruction_file" "Contains references to the retired toolkit workflow; retain project-specific instructions"
  fi
done

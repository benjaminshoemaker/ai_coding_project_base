---
description: Verify that a generated spec document preserves all upstream requirements and has no structural quality issues. Use after generating any spec document.
argument-hint: <document-type> [project-directory]
allowed-tools: Read, Edit, Grep, Glob, AskUserQuestion
---

Verify a specification document for context preservation (nothing important lost from upstream) and quality issues.

## Arguments

`$1` = Document type to verify. One of:
- `technical-spec` - Verify TECHNICAL_SPEC.md against PRODUCT_SPEC.md
- `execution-plan` - Verify EXECUTION_PLAN.md against TECHNICAL_SPEC.md
- `feature-technical` - Verify FEATURE_TECHNICAL_SPEC.md against FEATURE_SPEC.md
- `feature-plan` - Verify feature EXECUTION_PLAN.md against FEATURE_TECHNICAL_SPEC.md
- `product-spec` - Quality check only (no upstream document)
- `feature-spec` - Quality check only (no upstream document)

If `$1` is empty, ask the user which document to verify.

## Project Directory

By default, verify documents in the current working directory.

If `$2` is provided, treat `$2` as the project directory and verify documents under `$2` instead.

## Prerequisites

- The target document must exist in the project directory (current directory, or `$2` if provided)
- For context preservation checks, the upstream document must also exist

## Directory Guard (Wrong Directory Check)

If `$2` is not provided and the expected documents are not present in the current directory:
- Ask the user for the correct project directory path
- Tell them to `cd` into that directory (recommended), or re-run as `/verify-spec <type> <project-directory>`

## Process

Run `/spec-verification` -- it handles the full verification workflow (document
identification, context preservation checks, quality checks, interactive
resolution, and final reporting). Pass the resolved document type and project
directory as arguments.

## Output

Inline report showing:
- Context preservation results
- Quality check results
- Issues found and resolved
- Final status (PASSED / PASSED WITH NOTES / NEEDS REVIEW)

## Important

- Be **conservative** - only flag obvious, clear problems
- Maximum 5 CRITICAL issues per run (show most severe first)
- CRITICAL issues block; MAJOR issues are noted but don't block
- Upstream document edits require explicit confirmation

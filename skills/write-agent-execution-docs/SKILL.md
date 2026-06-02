---
name: write-agent-execution-docs
description: Create repository-grounded technical execution documents and handoff instructions for other coding agents. Use when Codex must write an implementation plan, docs/superpowers plan, executor brief, orchestration checklist, database-safe change plan, or post-implementation repair checklist before delegating work to another agent.
---

# Write Agent Execution Docs

Create an executor-ready document that another coding agent can follow without guessing. Ground every instruction in inspected repository evidence and preserve the repository's documentation conventions.

## Establish Scope

1. Read the applicable instruction hierarchy, including repository guidance and scoped docs such as `AGENTS.md`, `docs/superpowers`, architecture notes, and referenced feature documents.
2. Inspect the relevant code paths, tests, persistence models, and configuration before writing implementation steps.
3. Separate verified facts, inferred behavior, unresolved questions, and explicitly out-of-scope work.
4. Identify the requested operating mode:
   - For a plan-only request, write the document and stop.
   - For orchestration, save the plan, delegate its execution, independently review the result, repair omissions, verify the final state, and append execution evidence.
5. Store the artifact in the repository's established planning area. Prefer `docs/superpowers/plans/<area>/YYYY-MM-DD-<topic>.md` when `docs/superpowers` exists.

## Write The Plan

Use [references/execution-plan-template.md](references/execution-plan-template.md) as the document skeleton. Include only relevant sections, but do not omit risk-bearing sections merely because the change appears small.

Make the plan implementation-specific:

- Name concrete files, classes, methods, routes, collections, tables, indexes, and tests.
- Define behavioral invariants and acceptance criteria before implementation steps.
- Specify API contracts, validation rules, authorization, tenant boundaries, error mapping, and compatibility behavior.
- Specify persistence semantics: source of truth, atomicity, idempotency, optimistic concurrency, uniqueness, migration/backfill needs, and rollback behavior.
- Treat database inspection as read-only unless the user explicitly authorizes writes. Use only repository-approved access mechanisms and never expose secrets in the document.
- Include exact verification commands where the repository defines them.
- Mark assumptions clearly when evidence cannot be inspected.
- Keep the executor's allowed scope explicit. Prevent unrelated refactors and destructive cleanup.

## Prepare Agent Instructions

Write instructions as ordered implementation checkpoints. Each checkpoint must define:

1. Objective and affected surface.
2. Files and symbols expected to change.
3. Required invariants and failure behavior.
4. Focused tests to add or update.
5. Verification required before continuing.

Require the executor to preserve concurrent user changes, report blockers with evidence, and avoid claiming completion when required checks did not run.

## Orchestrate When Requested

When delegation tools are available and the user requests orchestration:

1. Give the executor the saved plan path, repository root, scope constraints, and required checks.
2. Ask the executor to implement and report changed files, tests, blockers, and unresolved risks.
3. Review the resulting diff independently against [references/review-checklist.md](references/review-checklist.md).
4. Repair missing behavior directly when feasible.
5. Run the strongest available verification suite.
6. Append a result section to the plan with implementation status, evidence, limitations, and residual risks.

Do not treat the executor's report as proof. Inspect the code and verification output yourself.

## Output Quality

Produce a plan that is:

- Executable: another agent can work checkpoint by checkpoint.
- Auditable: decisions trace back to repository evidence or explicit assumptions.
- Database-safe: race conditions, partial writes, legacy data, indexes, and migration behavior are addressed.
- Testable: each requirement has a verification path.
- Scoped: unrelated cleanup remains excluded.

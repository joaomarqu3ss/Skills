# Technical Execution Plan Template

Use the project's language and documentation style. Remove sections that are genuinely irrelevant.

## Header

- Title
- Date
- Status: planned, delegated, implemented, repaired, blocked
- Owner or executor when relevant
- Source request and referenced documents

## 1. Objective

State the behavior to deliver and the operational reason for the change.

## 2. Verified Current State

List inspected files, symbols, tests, database evidence, and observed constraints. Separate facts from inferences.

## 3. Scope

List in-scope behavior and explicit exclusions.

## 4. Invariants

Define rules that must remain true across success, retries, concurrency, legacy data, and failure paths.

## 5. Contract Changes

Document routes, DTOs, events, status codes, validation, compatibility, authorization, and tenant resolution.

## 6. Persistence Design

Document entities, collections or tables, indexes, atomic operations, concurrency control, idempotency, source of truth, migration or backfill, startup behavior, rollback, and read-only audit queries.

## 7. Implementation Map

For each checkpoint, name files and symbols, required behavior, edge cases, tests, and verification commands.

## 8. Test Matrix

Cover happy paths, validation, authorization, tenant isolation, not-found behavior, conflicts, duplicates, retries, concurrency, legacy records, and regression risks.

## 9. Observability And Rollout

Document logs, metrics, audit evidence, deployment ordering, compatibility window, rollback conditions, and known environment limitations.

## 10. Executor Constraints

State allowed scope, forbidden destructive actions, concurrent-change preservation, secret handling, and required completion report.

## 11. Acceptance Criteria

Write checkable criteria tied to tests, build output, or inspected runtime evidence.

## 12. Execution Result

Append after implementation: changed files, repairs applied after review, commands run, results, skipped checks with reasons, and residual risks.

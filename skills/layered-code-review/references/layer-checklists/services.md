# Business Logic & Services Layer — Review Checklist

Review every item against the changed files. Mark as ✅ PASS, ⚠️ CONCERN, or 🔴 ISSUE.

## Domain Correctness

- [ ] Business rules match the stated requirements (ask the user if unclear).
- [ ] State transitions are valid and enforced (e.g., can't go from "cancelled" to "active").
- [ ] Calculations, formulas, and algorithms are correct for edge values (zero, negative, max, boundary).
- [ ] Domain invariants are enforced at the service level, not just the caller.

## Error Handling & Failure Paths

- [ ] Every expected failure case is handled explicitly (not swallowed or generic-caught).
- [ ] Error messages are actionable and do not leak implementation details.
- [ ] Partial failures in multi-step operations are handled (compensate, rollback, or leave consistent state).
- [ ] Retry logic has backoff, max attempts, and idempotency guarantees.

## Side Effects & External Calls

- [ ] External service calls have timeouts and circuit breakers.
- [ ] Side effects (emails, notifications, events, webhooks) happen at the right lifecycle point.
- [ ] Side effects are not triggered on dry runs, previews, or validation-only paths.
- [ ] Duplicate side effects are prevented on retries.

## Concurrency & Race Conditions

- [ ] Shared mutable state is protected (locks, transactions, atomic operations).
- [ ] Time-of-check-to-time-of-use (TOCTOU) patterns are identified and mitigated.
- [ ] Concurrent writes to the same entity produce a defined outcome (last-write-wins, conflict error, merge).

## Code Structure & Maintainability

- [ ] Single Responsibility: each service/use-case does one thing well.
- [ ] Dependencies are injected, not hard-coded.
- [ ] Magic numbers and strings are named constants.
- [ ] Complex conditionals are extracted into clearly-named predicates.
- [ ] Dead code paths are removed, not commented out.

## Questions To Ask The User

- "This method handles [scenario] by [behavior]. Is that the intended business rule, or should [alternative]?"
- "When [operation] fails at step N, I see it [rolls back / does nothing / continues]. What's the expected behavior?"
- "This logic assumes [condition]. Under what circumstances could that assumption break?"
- "I see [service A] calls [service B] which calls back to [service A's data]. Is this circular dependency intentional?"

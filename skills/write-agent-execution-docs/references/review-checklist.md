# Post-Execution Review Checklist

Audit the implementation independently after another agent finishes.

## Scope And Contract

- Confirm the diff matches the plan and excludes unrelated refactors.
- Confirm API, DTO, event, and compatibility contracts match the documented behavior.
- Confirm failure cases return the intended status or error type.

## Security And Isolation

- Confirm authorization checks use the actual identity model.
- Confirm tenant resolution cannot cross company boundaries.
- Confirm privileged roles work with multi-role identities.
- Confirm logs, docs, and tests do not expose secrets.

## Persistence

- Confirm the write filter includes tenant ownership and concurrency predicates.
- Confirm updates are atomic where partial state would be invalid.
- Confirm retries, idempotency, duplicate-key behavior, and first-write races.
- Confirm unique and query indexes support the intended invariants.
- Confirm legacy records, tombstones, migrations, and startup synchronization preserve user configuration.
- Confirm read-only audits remain read-only.

## Tests And Evidence

- Confirm each invariant has a focused test or a documented reason it cannot be automated.
- Run formatting or diff checks, build, focused tests, and the broadest feasible suite.
- Record environment blockers precisely instead of presenting skipped checks as passing.
- Inspect the final diff and repository status before reporting completion.

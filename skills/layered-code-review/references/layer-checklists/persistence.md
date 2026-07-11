# Data & Persistence Layer — Review Checklist

Review every item against the changed files. Mark as ✅ PASS, ⚠️ CONCERN, or 🔴 ISSUE.

## Schema & Migrations

- [ ] New columns/fields have correct types, defaults, and nullability.
- [ ] Migrations are reversible or have a documented rollback plan.
- [ ] Migrations are safe for zero-downtime deployment (no locking full tables, no breaking reads).
- [ ] Column renames or removals are backward-compatible with running application versions.
- [ ] Seed data and backfill scripts handle existing records correctly.

## Query Safety & Performance

- [ ] New queries have supporting indexes (check with EXPLAIN or equivalent).
- [ ] N+1 query patterns are avoided (use eager loading, joins, or batch fetches).
- [ ] Unbounded queries have LIMIT/pagination (never SELECT * from a growing table without bounds).
- [ ] Queries use parameterized inputs (no string interpolation).
- [ ] Full table scans are justified or avoided.
- [ ] Read queries use read replicas where available.

## Atomicity & Consistency

- [ ] Multi-step writes are wrapped in transactions where partial state would be invalid.
- [ ] Optimistic concurrency (version fields, ETags) is used where concurrent writes are possible.
- [ ] Unique constraints enforce business uniqueness rules at the database level.
- [ ] Foreign key constraints or application-level checks maintain referential integrity.
- [ ] Soft-delete and tombstone patterns are consistent and queries filter appropriately.

## Idempotency & Retries

- [ ] Write operations are idempotent (safe to retry on network failure).
- [ ] Upsert semantics are correct (INSERT ON CONFLICT behavior is intentional).
- [ ] Duplicate-key handling is explicit and tested.

## Data Safety

- [ ] Sensitive data (PII, secrets, tokens) is encrypted at rest.
- [ ] Audit trails are maintained for critical mutations.
- [ ] Deletion operations are intentional (cascade behavior is understood).
- [ ] Backup and recovery implications of schema changes are considered.

## ORM & Repository Patterns

- [ ] Repository methods are focused (one query per method, not kitchen-sink finders).
- [ ] Raw SQL is justified and reviewed for injection.
- [ ] ORM lazy-loading traps are identified.
- [ ] Connection pool configuration is appropriate for the workload.

## Questions To Ask The User

- "This new column [X] defaults to [value]. What should happen to the [N] existing rows?"
- "I see no index on [column] but it's used in a WHERE clause by [query]. Is this table small enough to not need one?"
- "This migration adds [constraint]. Will it fail on existing data that violates it?"
- "When [entity] is deleted, [related entities] are [cascaded/orphaned]. Is that the intended behavior?"
- "This write does not use a transaction. If it fails midway, what state is acceptable?"

# Tests Layer — Review Checklist

Review every item against the changed files. Mark as ✅ PASS, ⚠️ CONCERN, or 🔴 ISSUE.

## Coverage & Completeness

- [ ] Every new public method/endpoint has at least one test.
- [ ] Happy path, failure path, and edge cases are all covered.
- [ ] Boundary values are tested (empty, zero, null, max, negative, Unicode, special chars).
- [ ] Error conditions return the expected error type/message/status.
- [ ] Previously broken behavior (bug fixes) has a regression test.

## Assertion Quality

- [ ] Assertions are specific (not just "no error" — assert the actual returned value/state).
- [ ] Assertions cover the full response shape, not just one field.
- [ ] Negative assertions exist ("this should NOT happen").
- [ ] Snapshot tests are justified and reviewed when they change (not blindly updated).

## Test Isolation

- [ ] Each test is independent (no reliance on execution order).
- [ ] Test data is created within the test, not shared mutable state.
- [ ] Database state is reset between tests (transactions, truncation, or fresh fixtures).
- [ ] External services are mocked/stubbed (no real network calls in unit tests).
- [ ] Time-dependent tests use controlled clocks, not `Date.now()` or `time.time()`.

## Test Design

- [ ] Test names describe the behavior, not the implementation ("should reject expired token" not "test_validate").
- [ ] Arrange-Act-Assert (AAA) or Given-When-Then structure is clear.
- [ ] Setup/teardown is minimal and relevant to the test.
- [ ] Parameterized tests are used for repetitive variations.
- [ ] Integration tests test real interactions, not re-mocked versions of unit tests.

## Flakiness & Reliability

- [ ] No sleep/delay calls that could cause timing-dependent failures.
- [ ] No reliance on filesystem paths, ports, or environment that varies between machines.
- [ ] Async tests properly await all promises/futures.
- [ ] Concurrent test execution does not cause interference.

## Questions To Ask The User

- "I see [function] is tested for the happy path but not for [edge case]. Is [edge case] possible in production?"
- "This test mocks [dependency] but the mock returns [simplified data]. Does the real [dependency] ever return [different shape]?"
- "These tests don't cover [scenario]. Is that covered by integration/e2e tests elsewhere, or is it a gap?"
- "This test name says [X] but it actually asserts [Y]. Which is the intended behavior?"

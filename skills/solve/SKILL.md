---
name: solve
description: "Pick up a tracked issue and drive it to closed."
disable-model-invocation: true
---

Resolve one tracked issue per run and close it.

1. Pick up the issue. With a number, fetch it; without one, take the oldest open issue carrying the repo's AFK-ready triage label. Follow `docs/agents/issue-tracker.md` and `docs/agents/triage-labels.md` when present, else `gh`. Done when the issue body and its labels are in context.
2. Implement the issue. Use /tdd where possible, at pre-agreed seams. Run typechecking regularly, single test files regularly, and the full test suite once at the end.
3. Once done, use /code-review to review the work, and apply what it finds.
4. Close the loop. Green baseline plus applied review is the bar: move labels per the repo's triage vocabulary and close with a comment summarising change and verification. Below the bar, comment the state instead and leave labels showing it.

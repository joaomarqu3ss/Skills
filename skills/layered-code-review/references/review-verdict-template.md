# Review Verdict Template

Use this template to produce the final, aggregated code review verdict after all layer subagents have completed their interactive reviews.

---

## Code Review Verdict

**Date:** {DATE}
**Reviewer:** Layered Code Review (AI-assisted)
**Change:** {DIFF_DESCRIPTION}
**Verdict:** {APPROVE | APPROVE WITH CONCERNS | REQUEST CHANGES}

---

### Executive Summary

{1-3 sentences summarizing the overall quality, risk level, and key takeaways from the review.}

---

### Layer Summaries

#### API & Routes
**Status:** {✅ Clean | ⚠️ Concerns | 🔴 Issues}
{1-2 sentence summary of this layer's findings.}

#### Business Logic & Services
**Status:** {✅ Clean | ⚠️ Concerns | 🔴 Issues}
{1-2 sentence summary.}

#### Data & Persistence
**Status:** {✅ Clean | ⚠️ Concerns | 🔴 Issues}
{1-2 sentence summary.}

#### Tests
**Status:** {✅ Clean | ⚠️ Concerns | 🔴 Issues}
{1-2 sentence summary.}

#### Infrastructure & Config
**Status:** {✅ Clean | ⚠️ Concerns | 🔴 Issues}
{1-2 sentence summary.}

---

### All Findings (Ranked by Severity)

| # | Severity | Layer | File:Line | Finding | Recommendation |
|---|----------|-------|-----------|---------|----------------|
| 1 | 🔴 ISSUE | | | | |
| 2 | ⚠️ CONCERN | | | | |
| 3 | ℹ️ NOTE | | | | |

---

### Cross-Layer Issues

{Issues that span multiple layers — e.g., API accepts input the service never validates, or the persistence layer has no index for a query the service uses frequently.}

| # | Layers Involved | Finding | Recommendation |
|---|-----------------|---------|----------------|
| 1 | | | |

---

### User Context Captured

{Summary of the questions asked to the user during the interactive review and the answers received. This section preserves institutional knowledge for future reviews.}

| Layer | Question | User's Answer |
|-------|----------|---------------|
| | | |

---

### Residual Risks

{Anything the review could not verify — e.g., runtime behavior that requires load testing, third-party service responses, production data characteristics.}

- {Risk 1}
- {Risk 2}

---

### Recommended Next Steps

1. {Action item — e.g., "Fix the 🔴 issues before merging"}
2. {Action item — e.g., "Add index on [column] before deploying to production"}
3. {Action item — e.g., "Schedule load test for [endpoint]"}

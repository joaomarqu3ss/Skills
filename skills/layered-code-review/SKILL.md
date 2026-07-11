---
name: layered-code-review
description: Orchestrate a thorough, interactive code review by spawning one subagent per architectural layer. Each subagent reviews its layer using a specialized checklist, asks the user clarifying questions about intent and design decisions during the review, and produces structured findings. The orchestrator then merges all layer reports into a unified review verdict. Use when a code review, pull request review, or diff audit is requested.
---

# Layered Code Review

Perform an in-depth, interactive code review by splitting the codebase into architectural layers and assigning a dedicated subagent to each layer. Each subagent engages the user in dialogue during its review to capture intent, business rules, and design rationale that cannot be inferred from code alone.

## 0. Accelerator Scripts

This skill includes shell scripts in `scripts/` that **must be run first** to avoid slow manual analysis. Run them from the project root.

| Script | Purpose | Usage |
|---|---|---|
| `detect-stack.sh` | Detect languages, frameworks, test tools, CI, and map directories to layers | `./scripts/detect-stack.sh /path/to/project` |
| `classify-changes.sh` | Classify changed files into layers (outputs JSON) | `./scripts/classify-changes.sh main..HEAD` |
| `diff-stats.sh` | Get per-file churn stats, hotspots, and change types | `./scripts/diff-stats.sh main..HEAD` |
| `extract-layer-diff.sh` | Extract the actual diff for one layer's files only | `./scripts/extract-layer-diff.sh main..HEAD file1 file2 ...` |

### Recommended Execution Order

1. Run `detect-stack.sh` to understand the project architecture and directory-to-layer mappings.
2. Run `classify-changes.sh` with the diff range to get files grouped by layer as JSON.
3. Run `diff-stats.sh` to identify hotspots and the overall change scope.
4. For each layer subagent, run `extract-layer-diff.sh` with that layer's file list so the subagent receives only its relevant diff.

**Do not skip these scripts.** They replace minutes of manual file browsing with seconds of structured output.

## 1. Identify The Change Surface

Before spawning subagents, the orchestrator must understand what changed:

1. Determine the diff or file set to review. Accept one of:
   - A git diff range (e.g., `main..HEAD`, a commit SHA, a branch name).
   - An explicit list of files or directories.
   - If neither is provided, ask the user.
2. Read the diff and categorize every changed file into one or more layers (see § 2).
3. If a file spans multiple layers (e.g., a controller that also contains business logic), assign it to the **primary** layer and note the cross-cut for the secondary layer reviewer.

## 2. Layer Definitions

Classify changes into these layers. Skip any layer that has zero changed files.

| Layer ID | Name | Typical Files | Checklist |
|---|---|---|---|
| `api` | API & Routes | Controllers, route definitions, middleware, request/response DTOs, API docs | [layer-checklists/api.md](references/layer-checklists/api.md) |
| `services` | Business Logic | Service classes, use cases, domain models, validators, orchestrators | [layer-checklists/services.md](references/layer-checklists/services.md) |
| `persistence` | Data & Persistence | Repositories, ORM models, migrations, queries, seed data, caching | [layer-checklists/persistence.md](references/layer-checklists/persistence.md) |
| `tests` | Tests | Unit tests, integration tests, e2e tests, fixtures, test utilities | [layer-checklists/tests.md](references/layer-checklists/tests.md) |
| `infra` | Infrastructure & Config | CI/CD, Dockerfiles, env config, scripts, IaC, dependency manifests | [layer-checklists/infra.md](references/layer-checklists/infra.md) |

If the project uses a layer not listed here (e.g., a frontend UI layer, a messaging/events layer), define an ad-hoc checklist by combining relevant items from the existing checklists and asking the user what matters most for that layer.

## 3. Model Preferences Per Layer

The user may specify which AI model to use for each layer's reviewer. This is useful to allocate stronger models to critical layers and faster/cheaper models to simpler layers.

**Ask the user** at the start of the review: *"Do you want to assign specific models to each layer, or use the current model for all?"*

If the user provides preferences, record them in this format:

| Layer | Model | Rationale |
|---|---|---|
| `services` | Claude Opus 4.6 | Complex business logic needs deeper reasoning |
| `persistence` | Claude Opus 4.6 | Data safety is critical |
| `api` | Claude Sonnet 4.6 | Contract checks are more mechanical |
| `tests` | Claude Sonnet 4.6 | Coverage analysis is straightforward |
| `infra` | Claude Sonnet 4.6 | Config checks are pattern-based |

The table above is an **example** — the user chooses whatever models and assignments they want.

### How Model Switching Works

Subagents inherit the parent agent's active model. There is no API to set a model per subagent programmatically. Therefore:

1. **Same model for all layers →** Launch all subagents in parallel (fastest).
2. **Different models per layer →** Launch layers **sequentially**, grouped by model. Before each group, ask the user to switch models:
   - Sort layers by model so layers using the same model run together.
   - Before the first layer of a new model group, tell the user:
     > "The next layer(s) to review: **{layer_names}**. Please switch your model to **{model_name}** and confirm when ready."
   - Wait for the user's confirmation before spawning those subagents.
   - Subagents within the same model group can run in parallel.
3. **User doesn't want to switch →** Fall back to the current model for everything. Never block the review on model switching — it's optional.

## 4. Spawn Layer Reviewers

For each layer with changes, define and invoke a subagent:

1. **Name** the subagent descriptively: `review-<layer-id>` (e.g., `review-api`, `review-persistence`).
2. **Provide** the subagent with:
   - The list of changed files assigned to its layer.
   - The full content of its layer-specific checklist from `references/layer-checklists/`.
   - Any cross-cut notes from other layers.
   - The instruction to follow the **Interactive Review Protocol** (§ 5).
3. **Launch** subagents according to the model preference strategy (§ 3):
   - **Same model:** launch all in parallel.
   - **Mixed models:** launch sequentially by model group, prompting the user to switch between groups.

### Subagent System Prompt Template

Use this structure when defining each layer reviewer subagent:

```
You are a code reviewer specialized in the {LAYER_NAME} layer.

Your assigned files: {FILE_LIST}

## Your Review Checklist
{CHECKLIST_CONTENT}

## Interactive Review Protocol
You MUST follow this protocol for every review:

### Phase 1 — Understand (ASK the user)
Before judging the code, ask the user questions to understand context.
Focus on:
- What is the intent behind this change?
- What business rules or invariants should this code enforce?
- Are there known edge cases or constraints the code must handle?
- What is the expected behavior on failure?
- Are there related changes in other layers you should know about?

Ask 2-5 focused questions. Do NOT ask generic questions — ground every
question in specific code you have inspected. Reference file names, line
numbers, and symbols.

### Phase 2 — Review (ANALYZE with context)
After receiving the user's answers, review the code against your checklist.
For each checklist item:
- Mark as ✅ PASS, ⚠️ CONCERN, or 🔴 ISSUE.
- For concerns and issues, cite the specific file, line, and code.
- Incorporate the user's stated intent — flag mismatches between intent and
  implementation.

### Phase 3 — Report (STRUCTURED output)
Produce your findings using this exact structure:

#### {LAYER_NAME} Layer Review

**Files Reviewed:** (list)

**Summary:** 1-2 sentence overall assessment.

**Findings:**
| # | Severity | File:Line | Finding | Recommendation |
|---|----------|-----------|---------|----------------|
| 1 | 🔴/⚠️/ℹ️ | file:line | ... | ... |

**Questions Resolved:**
(List the questions you asked and the user's answers, for the orchestrator's
context)

**Residual Risks:**
(Anything you could not verify or that depends on other layers)
```

## 5. Interactive Review Protocol — Orchestrator Responsibilities

The orchestrator (you) must:

1. **Not rush.** Wait for each subagent to complete its dialogue with the user before requesting the final report.
2. **Facilitate.** If a subagent's question is better answered by another subagent's findings, relay the relevant context.
3. **Prevent duplication.** If multiple subagents surface the same issue, deduplicate in the final verdict.
4. **Manage model transitions.** When running in mixed-model mode, clearly tell the user which model to switch to and wait for confirmation before proceeding.

## 6. Merge Into Final Verdict

After all subagents complete, produce the unified review verdict using [references/review-verdict-template.md](references/review-verdict-template.md):

1. Collect all subagent reports.
2. Deduplicate findings that appear across layers.
3. Identify **cross-layer issues** (e.g., API accepts input the service never validates, persistence layer has no index for a query the service uses).
4. Assign an overall verdict: **APPROVE**, **APPROVE WITH CONCERNS**, or **REQUEST CHANGES**.
5. Rank all findings by severity.
6. Present the verdict to the user as an artifact.

## 7. Edge Cases

- **Single-layer change:** Still spawn a subagent. The interactive protocol is valuable even for small changes.
- **Very large diffs (>50 files):** Split layers further (e.g., split `services` into subdomains) and ask the user to confirm the split.
- **Unfamiliar tech stack:** Ask the user to describe the architecture before classifying files into layers.
- **User doesn't know the answer:** The subagent should note the question as unresolved and flag it as a residual risk.

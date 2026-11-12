---
name: how
description: "Use for \"how does X work\", code walkthroughs before changing something, and placement / ownership / layering questions (\"where should this live\", \"which package owns this\", \"is this the right layer\"). Explains subsystem architecture, runtime flow, onboarding mental models. Use why for motivation."
disable-model-invocation: true
---

# How

Explore the codebase to answer "how does X work?" questions. Produce architectural explanations at the level of a senior engineer onboarding onto a subsystem, enough to build a working mental model, not so much that it reads like annotated source code.

Explorers use the `how explorer` line in `~/.gemini/config/rules/pstack-models.md` (default Hydrogen / Gemini Flash: `gemini-4-hydrogen-high` when entitled, otherwise `gemini-3.8-flash-high`), and every explainer uses the `how explainer` line (default `claude-opus-5-5-high`). Never select or fall back to `gpt-oss-*`. Use read-only `invoke_subagent` calls with `TypeName: "research"` (`Model: "flash"` for Hydrogen / Flash explorers, `Model: "pro"` for Argon / Carbon, or `Model: "inherit"` when `auto`, `inherit-parent`, or matching the parent model), or `swarm(action: "add", model: "<slug>", workspace: "inherit", ...)` with read-only instructions when pinning an exact cross-family slug (checking `swarm(action: "models", all: true)` first and substituting `gemini-4-carbon-high` if `claude-*` quota is `0%`, then calling `swarm(action: "kill")` when done). Pick each subagent's reasoning level for the job, per the Subagents section of the **poteto-mode** skill.

## 1. Assess complexity

If the scope is ambiguous, state your interpretation and explore. The user can redirect.

- **Simple** (a single module, a small utility, a narrow question such as "how does function X work"): no explorers. Spawn one explainer that explores and explains in one pass, built from `references/explainer-prompt.md` without the explorer-findings section. Go to step 4.
- **Complex** (a subsystem spanning multiple files or services, a cross-cutting feature, a full architectural overview): go to step 2.

When in doubt, take the simple path.

## 2. Explore (complex only)

Decompose the question into 2 to 4 angles, each a distinct slice of the subsystem. Spawn all explorers in parallel in the same assistant turn (one `invoke_subagent` call per explorer), each with `references/explorer-prompt.md` and its angle filled in.

## 3. Synthesize (complex only)

Once all explorers have returned, spawn one explainer with `references/explainer-prompt.md` and every explorer's findings filled in.

## 4. Present

Present the explainer's output. Light edits for clarity or context from the conversation are fine. Do not substantially rewrite it.

## Output format

The explanation uses the sections defined in `references/explainer-prompt.md`, dropping any that do not apply: Overview, Key Concepts, How It Works, Where Things Live, Gotchas.

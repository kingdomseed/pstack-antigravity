---
name: setup-pstack
description: Configure which models pstack uses per role and at what reasoning budget. Detects your available models and writes an always-applied rule that overrides the skill defaults. Use for /setup-pstack, "configure pstack models", "pstack budget", or changing pstack's model choices.
---

# Setup pstack

Write `~/.gemini/config/rules/pstack-models.md` (and mirror to `~/.gemini/pstack-models.md`), an always-on Antigravity rule that sets pstack's model per role.

## Steps

### 1. Detect available models

Run `agy models` (or `/Users/jasonholt/.local/bin/agy models`) to enumerate the exact model slugs entitled in this Antigravity installation (such as `gemini-4-argon-high`, `gemini-4-argon-medium`, `gemini-4-argon-low`, `gemini-3.8-flash-high`, `gemini-3.8-flash-medium`, `gemini-3.8-flash-low`, `claude-opus-5-5-high`, `claude-opus-5-5-medium`, `claude-opus-5-5-low`, `claude-sonnet-5-5-high`, `claude-sonnet-5-5-medium`, `claude-sonnet-5-5-low`, `gpt-oss-120b-medium`). If running inside T3 Code, you may also inspect `orchestrator_capabilities`. If you cannot detect any, ask the user to paste the slugs they have access to. Never write a real slug you have not confirmed is available. The aliases `inherit-parent` and `auto`, plus in-session `invoke_subagent` tiers (`pro`, `flash`, `flash_lite`), are always valid.

### 2. Load current state

The default role-to-model mapping is the rule shape shown in step 5 below (and in `scripts/pstack-models.default.md`). If `~/.gemini/config/rules/pstack-models.md` or `~/.gemini/pstack-models.md` already exists, read it and treat its `# budget` line and its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5, such as `how critics`, is from a retired role. Drop it.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer `ask_question` over free text. Offer these four options with these exact labels, and name the current budget when the rule records one. With no rule, say that `large` / `medium` matches the skill defaults (`high` model slugs, with `xhigh` or `max` effort when invoked via `agy --effort`).

- `unlimited — max reasoning`
- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

**(b) Apply it.** Build the working table from the skill defaults, and on a re-run keep any role you changed by family, list, or alias (`inherit-parent`, `auto`). `unlimited`, `large`, `medium`, and `small` set the effort token of every real slug, panel entries included, to `max`, `xhigh`, `high`, or `medium`. The effort token is the last token on the ladder `max` > `xhigh` > `high` > `medium` > `low`. If the result is not a detected slug, use the same family's detected slug with the highest effort at or below the target, else mark the role as needing a choice. `inherit-parent` and `auto` do not change. Antigravity model slugs (`gemini-4-argon-*`, `claude-opus-5-5-*`, `claude-sonnet-5-5-*`, `gemini-3.8-flash-*`) top out at `-high` (`-low`, `-medium`, `-high`), so under `unlimited` and `large` the slug fallback keeps `claude-opus-5-5-high` and `gemini-4-argon-high` while recording `# budget: unlimited (max)` or `# budget: large (xhigh)` for `agy --effort`. `small` turns them into `claude-opus-5-5-medium` and `gemini-4-argon-medium`.

**(c) Show the roles and confirm.** Show every role with its model, marking any real slug not in the detected set as needing a choice. Also list each line step 2 dropped. Ask whether to accept as-is or change specific roles, offering the detected models plus `inherit-parent` and `auto` (both mean: this role runs on the parent chat model via `Model: "inherit"`, which is how session-model users stay on the parent model) as the options. Prefer `ask_question` over free text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, alias entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena selects one value from it whose model family differs from the parent's when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every real slug written must be in the detected set. `inherit-parent` and `auto` always pass. If a chosen real slug is not available, stop and ask again.

### 5. Write the rule

Write `~/.gemini/config/rules/pstack-models.md` with `trigger: always_on`, a `# budget` line with the chosen label and its target effort, and one line per role, using the same labels poteto-mode uses. Also write the role lines to `~/.gemini/pstack-models.md`. Overwrite the whole file so re-runs stay idempotent. Shape:

```
---
trigger: always_on
description: pstack per-role model choices (overrides skill defaults)
---
# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (`Model: "inherit"` in `invoke_subagent`). Alias entries in a panel list still count toward its fan-out.
# budget: large (xhigh)
feature, refactoring: gemini-4-argon-high
bug-fix: gemini-4-argon-high
perf-issue: gemini-4-argon-high
hillclimb: gemini-4-argon-high
judgment and prose: claude-opus-5-5-high
hardest tasks: claude-opus-5-5-high
how explorer: gemini-4-argon-high
how explainer: claude-opus-5-5-high
why investigators: gemini-4-argon-high
why synthesizer: claude-opus-5-5-high
reflect tooling: gemini-4-argon-high
reflect judgment, divergent, synthesizer: claude-opus-5-5-high
arena runners: claude-opus-5-5-high, gemini-4-argon-high
arena cross-judge pool: claude-opus-5-5-high, gemini-4-argon-high
swarm workers: gemini-4-argon-high
architect runners: claude-opus-5-5-high, gemini-4-argon-high
interrogate reviewers: claude-opus-5-5-high, gemini-4-argon-high
```

### 6. Confirm

Tell the user the rule was written to `~/.gemini/config/rules/pstack-models.md` and `~/.gemini/pstack-models.md`, and that it applies to new sessions. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill under `.agents/skills/`, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.

### 8. Offer a formal verification skill (optional)

Check whether the project already has a formal verification skill (a project skill that runs a model checker, a proof, or another verifier against the code). If not, offer once: "want a formal verification skill, so agents can prove a key property of your code holds in every case in scope, not only the cases tests reach? I can generate one with /create-formal-verification-skill." On yes, invoke `/create-formal-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.

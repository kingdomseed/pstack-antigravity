---
name: setup-pstack
description: Configure which models pstack uses per role and at what reasoning budget. Detects your available models and writes an always-applied rule that overrides the skill defaults. Use for /setup-pstack, "configure pstack models", "pstack budget", or changing pstack's model choices.
---

# Setup pstack

Write `~/.gemini/config/rules/pstack-models.md` (and mirror to `~/.gemini/pstack-models.md` plus any `~/.t3/userdata/providers/antigravity/*/config/rules/pstack-models.md`), an always-on Antigravity rule that sets pstack's model per role.

## Steps

### 1. Detect available models

Call `swarm(action: "models", all: true)` first (and/or run `agy models`) to enumerate the exact model slugs and live quotas entitled in this Antigravity installation:

- **Gemini 4 Carbon**: `gemini-4-carbon-high`, `gemini-4-carbon-medium`, `gemini-4-carbon-low`
- **Gemini 4 Argon**: `gemini-4-argon-high`, `gemini-4-argon-medium`, `gemini-4-argon-low`
- **Hydrogen / Gemini Flash**: `gemini-4-hydrogen-high`, `gemini-4-hydrogen-medium`, `gemini-4-hydrogen-low` when present in the catalog, otherwise `gemini-3.8-flash-high`, `gemini-3.8-flash-medium`, `gemini-3.8-flash-low`
- **Claude Opus 5.5**: `claude-opus-5-5-high`, `claude-opus-5-5-medium`, `claude-opus-5-5-low`
- **Claude Sonnet 5.5**: `claude-sonnet-5-5-high`, `claude-sonnet-5-5-medium`, `claude-sonnet-5-5-low`

**Hard exclusion:** Filter out `gpt-oss-*` (`gpt-oss-120b-medium`) immediately. Never offer `gpt-oss-*`, keep it in a role, or write it to the rule.

If running inside T3 Code without `swarm`, inspect `orchestrator_capabilities` or `agy models`. If you cannot detect any models, ask the user to paste the slugs they have access to. Never write a real slug you have not confirmed is available in the catalog (note: `0%` live quota in `swarm(action: "models")` is a temporary runtime quota state, not a missing entitlement, so an entitled slug with `0%` current quota remains valid to configure while noting its reset time). The aliases `inherit-parent` and `auto` are always valid.

### 2. Load current state

The default role-to-model mapping is the rule shape shown in step 5 below (and in `scripts/pstack-models.default.md`), preferring `gemini-4-hydrogen-*` over `gemini-3.8-flash-*` for the fast exploration roles when `gemini-4-hydrogen-*` is in the detected catalog. If `~/.gemini/config/rules/pstack-models.md` or `~/.gemini/pstack-models.md` already exists, read it and treat its `# budget` line and its role values as the current choices. Drop any retired role line not in step 5 (such as `how critics`), and drop any `gpt-oss-*` entry as excluded so step 3 replaces it.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer `ask_question` over free text. Offer these four options with these exact labels, and name the current budget when the rule records one. With no rule, say that `medium` / `large` matches the skill defaults (`-high` model slugs, with `xhigh` or `max` effort recorded for `agy --effort` CLI runs).

- `unlimited — max reasoning`
- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

**(b) Apply it.** Build the working table from the skill defaults, and on a re-run keep any role you changed by family/tier, list, or alias (`inherit-parent`, `auto`). `unlimited`, `large`, `medium`, and `small` set the effort token of every real slug, panel entries included, to `max`, `xhigh`, `high`, or `medium`. The effort token is the last token on the ladder `max` > `xhigh` > `high` > `medium` > `low`. If the result is not a detected slug, use the same model tier's detected slug with the highest effort at or below the target, else mark the role as needing a choice. `inherit-parent` and `auto` do not change. Antigravity model slugs (`gemini-4-carbon-*`, `gemini-4-argon-*`, `gemini-4-hydrogen-*` / `gemini-3.8-flash-*`, `claude-opus-5-5-*`, `claude-sonnet-5-5-*`) top out at `-high` (`-low`, `-medium`, `-high`), so under `unlimited` and `large` the slug fallback keeps `-high` while recording `# budget: unlimited (max)` or `# budget: large (xhigh)` for `agy --effort`. `small` turns them into `-medium`.

**(c) Show the roles and confirm.** Show every role with its model (and note any family currently at `0%` quota from `swarm(action: "models")`), marking any real slug not in the detected set as needing a choice. Also list each line step 2 dropped. Ask whether to accept as-is or change specific roles, offering the detected allowed models (Carbon, Argon, Hydrogen / Flash, Opus 5.5, Sonnet 5.5; never `gpt-oss-*`) plus `inherit-parent` and `auto` (both mean: this role runs on the parent chat model, which is how Auto/session-model users stay on the parent model) as the options. Prefer `ask_question` over free text. For panel roles (`arena runners`, `architect runners`, `interrogate reviewers`) the value is a list, and one subagent or `swarm` worker runs per entry, alias entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena runs one judge. It tries only values from a family other than the parent's (`claude-*` vs `gemini-*`), in list order, so order it by preference. An `inherit-parent` or `auto` value never judges. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every real slug written must be in the detected allowed set and must not match `gpt-oss-*`. `inherit-parent` and `auto` always pass. If a chosen real slug is not available, stop and ask again.

### 5. Write the rule

Write `~/.gemini/config/rules/pstack-models.md` with `trigger: always_on`, a `# budget` line with the chosen label and its target effort, and one line per role, using the same labels poteto-mode uses. Also write the role lines to `~/.gemini/pstack-models.md` (and update `~/.t3/userdata/providers/antigravity/*/config/rules/pstack-models.md` when that directory exists). Overwrite the whole file so re-runs stay idempotent. Shape (using `gemini-4-hydrogen-high` in place of `gemini-3.8-flash-high` once `gemini-4-hydrogen-*` is detected):

```
---
trigger: always_on
description: pstack per-role model choices (overrides skill defaults)
---
# pstack model configuration for Antigravity. One line per role. Delete a line to fall back to the skill default.
# Allowed families: Gemini 4 Carbon (`gemini-4-carbon-*`), Gemini 4 Argon (`gemini-4-argon-*`), Hydrogen / Gemini Flash (`gemini-4-hydrogen-*` when entitled, otherwise `gemini-3.8-flash-*`), Claude Opus 5.5 (`claude-opus-5-5-*`), and Claude Sonnet 5.5 (`claude-sonnet-5-5-*`).
# Excluded: `gpt-oss-*` (`gpt-oss-120b-medium`) is never selected, offered, or used as a fallback.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (`Model: "inherit"` in `invoke_subagent`). Alias entries in a panel list still count toward its fan-out.
# Exact model slugs and live quotas come from `swarm(action: "models", all: true)` (or `agy models`). Pin exact cross-family slugs natively with `swarm(action: "add", model: "<slug>", workspace: ...)` (or headless `agy --model <slug> --effort <level> -p='...'`). `invoke_subagent` accepts `Model: "inherit" | "pro" | "flash" | "flash_lite"`.
# budget: medium (high)
feature, refactoring: gemini-4-argon-high
bug-fix: gemini-4-carbon-high
perf-issue: gemini-4-carbon-high
hillclimb: gemini-4-carbon-high
judgment and prose: claude-opus-5-5-high
hardest tasks: claude-opus-5-5-high
how explorer: gemini-3.8-flash-high
how explainer: claude-opus-5-5-high
why investigators: gemini-3.8-flash-high
why synthesizer: claude-opus-5-5-high
reflect tooling: gemini-3.8-flash-high
reflect judgment, divergent, synthesizer: claude-opus-5-5-high
arena runners: claude-opus-5-5-high, gemini-4-carbon-high, claude-sonnet-5-5-high
arena cross-judge pool: claude-opus-5-5-high, gemini-4-carbon-high, gemini-4-argon-high
swarm workers: gemini-4-argon-high
architect runners: claude-opus-5-5-high, gemini-4-carbon-high, claude-sonnet-5-5-high
interrogate reviewers: claude-opus-5-5-high, gemini-4-carbon-high
```

### 6. Confirm

Tell the user the rule was written to `~/.gemini/config/rules/pstack-models.md` and `~/.gemini/pstack-models.md`, and that it applies to new sessions. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill under `.agents/skills/`, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.

### 8. Offer a formal verification skill (optional)

Check whether the project already has a formal verification skill (a project skill that runs a model checker, a proof, or another verifier against the code). If not, offer once: "want a formal verification skill, so agents can prove a key property of your code holds in every case in scope, not only the cases tests reach? I can generate one with /create-formal-verification-skill." On yes, invoke `/create-formal-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.

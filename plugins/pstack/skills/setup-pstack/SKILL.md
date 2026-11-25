---
name: setup-pstack
description: Configure which models pstack uses per role and at what reasoning budget. Detects your available models and writes an always-applied rule that overrides the skill defaults. Use for /setup-pstack, "configure pstack models", "pstack budget", or changing pstack's model choices.
---

# Setup pstack

Write `~/.gemini/config/rules/pstack-models.md` (and mirror to `~/.gemini/pstack-models.md` plus any `~/.t3/userdata/providers/antigravity/*/config/rules/pstack-models.md`), an always-on Antigravity rule that sets pstack's model per role.

## Steps

### 1. Detect available models

Call `swarm(action: "models", all: true)` first (and/or run `agy models`) to enumerate the exact model slugs and live quotas entitled in this Antigravity installation across the four allowed tiers:

- **Gemini 4 Neon**: `gemini-4-neon-xhigh`, `gemini-4-neon-high`, `gemini-4-neon-medium`, `gemini-4-neon-low`
- **Gemini 4 Carbon**: `gemini-4-carbon-high`, `gemini-4-carbon-medium`, `gemini-4-carbon-low`
- **Gemini 4 Hydrogen / Flash**: `gemini-4-hydrogen-xhigh`, `gemini-4-hydrogen-high`, `gemini-4-hydrogen-medium`, `gemini-4-hydrogen-low` when present in the catalog, otherwise `gemini-3.8-flash-high`, `gemini-3.8-flash-medium`, `gemini-3.8-flash-low`
- **Claude Opus 5.5**: `claude-opus-5-5-high`, `claude-opus-5-5-medium`, `claude-opus-5-5-low`

**Hard exclusion:** Filter out `gemini-4-argon-*`, `claude-sonnet-5-5-*`, and `gpt-oss-*` (`gpt-oss-120b-medium`) immediately. Never offer them, keep them in a role, or write them to the rule.

If running inside T3 Code without `swarm`, inspect `orchestrator_capabilities` or `agy models`. If you cannot detect any models, ask the user to paste the slugs they have access to. Never write a real slug you have not confirmed is available in the catalog (note: `0%` live quota in `swarm(action: "models")` is a temporary runtime quota state, not a missing entitlement, so an entitled slug with `0%` current quota remains valid to configure while noting its reset time). The aliases `inherit-parent` and `auto` are always valid.

### 2. Load current state

The default role-to-model mapping is the rule shape shown in step 5 below (and in `scripts/pstack-models.default.md`). If `~/.gemini/config/rules/pstack-models.md` or `~/.gemini/pstack-models.md` already exists, read it and treat its `# budget` line and its role values as the current choices. Otherwise start from those defaults.

Drop any line whose role is not in step 5 (such as `hardest tasks`, `how explorer`, `how explainer`, `why investigators`, `why synthesizer`, `reflect tooling`, `reflect judgment, divergent, synthesizer`, `architect runners`, or `how critics`), and drop any excluded slug (`gemini-4-argon-*`, `claude-sonnet-5-5-*`, `gpt-oss-*`) so step 3 replaces it with the role's default.

Older defaults put `gemini-4-neon-high` or another `gemini-4-*` entry in panel seats. In any rule, a `gemini-4-neon-high` entry or a `gemini-4-*` entry other than `gemini-4-neon-*` and `gemini-4-carbon-*` in a panel role (`arena runners`, `arena cross-judge pool`, `interrogate reviewers`) is an old default and becomes `gemini-4-neon-xhigh` (while keeping `gemini-4-carbon-high` when configured as its own Carbon seat). Any other Gemini 4 Neon level is the user's choice and stays. Tell the user which entries you replaced.

A rule without the `# defaults: 3` line comes from an older setup. Before step 3, migrate these old-setup values:

- A `# budget: unlimited` line becomes `large`, because no role runs above `xhigh`.
- An excluded slug (`gemini-4-argon-*`, `claude-sonnet-5-5-*`, `gpt-oss-*`) or `grok-*` slug in `feature, refactoring`, `bug-fix`, `perf-issue`, `hillclimb`, or `swarm workers` takes the role's step 5 default.
- In a panel role (`arena runners`, `arena cross-judge pool`, `interrogate reviewers`), any excluded slug in the list is replaced by the missing tier from the role's step 5 list, deduplicated.

Every other value is the user's choice and stays, including every `inherit-parent` or `auto` value. Tell the user which values you replaced.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer `ask_question` over free text. Offer these three options with these exact labels, and name the current budget when the rule records one. With no rule, say that `large` matches the skill defaults.

- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

**(b) Apply it.** Build the working table from the skill defaults, and on a re-run keep any role you changed by family/tier, list, or alias (`inherit-parent`, `auto`). Families are `claude-*` (Opus 5.5) and `gemini-*` (Neon `gemini-4-neon-*`, Carbon `gemini-4-carbon-*`, Hydrogen / Flash `gemini-4-hydrogen-*` or `gemini-3.8-flash-*`). Each role has a target effort, which is its default's effort moved by the budget: `large` keeps it, `medium` lowers it one step, and `small` lowers it two steps, on the ladder `xhigh` > `high` > `medium` > `low`. No role runs above `xhigh`, and a target at the bottom of the ladder stays there. Set the effort token (the last token) of every real slug in the role, panel entries included, to the role's target. If the result is not a detected slug, use the same tier's detected slug with the highest effort at or below the target, else mark the role as needing a choice. `inherit-parent` and `auto` do not change. Under `large`, `gemini-4-neon-xhigh` stays `gemini-4-neon-xhigh`, while `gemini-4-carbon-high` and `claude-opus-5-5-high` stay `-high` because those tiers top out at `high` in Antigravity; `medium` turns `gemini-4-neon-xhigh` into `gemini-4-neon-high` and `-high` roles into `-medium`; `small` turns `gemini-4-neon-xhigh` into `gemini-4-neon-medium` and `-high` roles into `-medium` (when `swarm workers` defaults to `high`, `medium` sets it to `medium` and `small` sets it to `medium` or `low` per step).

**(c) Show the roles and confirm.** Show every role with its model (and note any family currently at `0%` quota from `swarm(action: "models")`), marking any real slug not in the detected set as needing a choice. Also list each line step 2 dropped or replaced. Ask whether to accept as-is or change specific roles, offering the detected allowed models at `xhigh` or below (Opus 5.5, Neon, Carbon, Hydrogen / Flash; never `gemini-4-argon-*`, `claude-sonnet-5-5-*`, or `gpt-oss-*`) plus `inherit-parent` and `auto` (both mean: this role runs on the parent chat model) as the options. Prefer `ask_question` over free text. For panel roles (`arena runners`, `interrogate reviewers`) the value is a list, and one subagent or `swarm` worker runs per entry, alias entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena runs one judge. It tries only values from a vendor other than the parent's (`claude-*` vs `gemini-*`), in list order, so order it by preference. An `inherit-parent` or `auto` value never judges. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every real slug written must be in the detected allowed set, at `xhigh` or below, and must not match `gemini-4-argon-*`, `claude-sonnet-5-5-*`, or `gpt-oss-*`. `inherit-parent` and `auto` always pass. If a chosen real slug is not available, stop and ask again.

### 5. Write the rule

Write `~/.gemini/config/rules/pstack-models.md` with `trigger: always_on`, the `# defaults: 3` line, a `# budget` line with the chosen label and the effort that label names, and one line per role, using the same labels poteto-mode uses. Also write the role lines to `~/.gemini/pstack-models.md` (and update `~/.t3/userdata/providers/antigravity/*/config/rules/pstack-models.md` when that directory exists). Overwrite the whole file so re-runs stay idempotent. Shape:

```
---
trigger: always_on
description: pstack per-role model choices (overrides skill defaults)
---
# pstack model configuration for Antigravity. One line per role. Delete a line to fall back to the skill default.
# Allowed families: Claude Opus 5.5 (`claude-opus-5-5-*`), Gemini 4 Neon (`gemini-4-neon-*`, supports `xhigh`), Gemini 4 Carbon (`gemini-4-carbon-*`), and Gemini 4 Hydrogen (`gemini-4-hydrogen-*` when entitled, otherwise `gemini-3.8-flash-*`).
# Excluded: `gemini-4-argon-*`, `claude-sonnet-5-5-*`, and `gpt-oss-*` (`gpt-oss-120b-medium`) are retired/excluded and never selected, offered, or used as fallbacks.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (`Model: "inherit"` in `invoke_subagent`, or omit `model` in `swarm`). Alias entries in a panel list still count toward its fan-out.
# Exact model slugs and live quotas come from `swarm(action: "models", all: true)` (or `agy models`). Pin exact cross-family slugs natively with `swarm(action: "add", model: "<slug>", workspace: ...)` (or headless `agy --model <slug> --effort <level> -p='...'`). `invoke_subagent` accepts `Model: "inherit" | "pro" | "flash" | "flash_lite"`.
# When a configured family has `0%` quota in `swarm(action: "models")`, report the substitution and map `claude-opus-5-5-*` <-> `gemini-4-neon-xhigh` / `gemini-4-carbon-high` (and `gemini-4-neon-*` <-> `gemini-4-carbon-high`), deduplicating repeated panel seats and never using `gemini-4-argon-*`, `claude-sonnet-5-5-*`, or `gpt-oss-*`.
# defaults: 3
# budget: large (xhigh)
feature, refactoring: gemini-4-neon-xhigh
bug-fix: gemini-4-carbon-high
perf-issue: gemini-4-carbon-high
hillclimb: gemini-4-carbon-high
judgment and prose: gemini-4-neon-xhigh
arena runners: claude-opus-5-5-high, gemini-4-carbon-high, gemini-4-neon-xhigh
arena cross-judge pool: claude-opus-5-5-high, gemini-4-neon-xhigh, gemini-4-carbon-high
swarm workers: gemini-4-neon-high
interrogate reviewers: claude-opus-5-5-high, gemini-4-neon-xhigh, gemini-4-carbon-high
```

### 6. Confirm

Tell the user the rule was written to `~/.gemini/config/rules/pstack-models.md` and `~/.gemini/pstack-models.md`, and that it applies to new sessions. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill under `.agents/skills/`, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.

### 8. Offer a formal verification skill (optional)

Check whether the project already has a formal verification skill (a project skill that runs a model checker, a proof, or another verifier against the code). If not, offer once: "want a formal verification skill, so agents can prove a key property of your code holds in every case in scope, not only the cases tests reach? I can generate one with /create-formal-verification-skill." On yes, invoke `/create-formal-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.

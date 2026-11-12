# pstack model configuration for Antigravity. One line per role. Delete a line to fall back to the skill default.
# Allowed families: Gemini 4 Carbon (`gemini-4-carbon-*`), Gemini 4 Argon (`gemini-4-argon-*`), Hydrogen / Gemini Flash (`gemini-4-hydrogen-*` when entitled, otherwise `gemini-3.8-flash-*`), Claude Opus 5.5 (`claude-opus-5-5-*`), and Claude Sonnet 5.5 (`claude-sonnet-5-5-*`).
# Excluded: `gpt-oss-*` (`gpt-oss-120b-medium`) is never selected, offered, or used as a fallback.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (`Model: "inherit"` in `invoke_subagent`). Alias entries in a panel list still count toward its fan-out.
# Exact model slugs and live quotas come from `swarm(action: "models", all: true)` (or `agy models`). Pin exact cross-family slugs natively with `swarm(action: "add", model: "<slug>", workspace: ...)` (or headless `agy --model <slug> --effort <level> -p='...'`). `invoke_subagent` accepts `Model: "inherit" | "pro" | "flash" | "flash_lite"`.
# When a configured family has `0%` quota in `swarm(action: "models")`, report the substitution and map `claude-opus-5-5-*` -> `gemini-4-carbon-high` and `claude-sonnet-5-5-*` -> `gemini-4-argon-high` (or vice versa when `gemini-*` is at `0%`), deduplicating repeated panel seats and never using `gpt-oss-*`.
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

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

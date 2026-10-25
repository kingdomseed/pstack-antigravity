# pstack model configuration for Antigravity. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (`Model: "inherit"` in `invoke_subagent`). Alias entries in a panel list still count toward its fan-out.
# In-session `invoke_subagent` accepts `Model: "inherit" | "pro" | "flash" | "flash_lite"`, where `pro` maps to `gemini-4-argon-*` and `flash` maps to `gemini-3.8-flash-*`.
# Exact cross-family slugs (`claude-opus-5-5-high`, `claude-sonnet-5-5-high`, `gemini-4-argon-high`, `gemini-3.8-flash-high`) run via `agy -p --model <slug>`, `/model <slug> <prompt>`, or T3 Code `delegate_task`.
# budget: medium (high)
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

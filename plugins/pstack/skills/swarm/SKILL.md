---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage, races, gauntlets, and exploration."
disable-model-invocation: true
---

# Swarm

## Start

Track one checklist entry per phase with `update_steps` before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Pick the worker model from the `swarm workers` line in `~/.gemini/config/rules/pstack-models.md` after checking `swarm(action: "models", all: true)`. If the rule or that line is missing, use `gemini-4-neon-high`. Never select or fall back to `gemini-4-argon-*`, `claude-sonnet-5-5-*`, or `gpt-oss-*`. For `auto` or `inherit-parent`, omit `model` in `swarm` (or pass `Model: "inherit"` in `invoke_subagent`) so the workers run on the parent model. If `swarm` rejects a slug, use `gemini-4-neon-high` and say so. If the configured family has `0%` quota, apply poteto-mode's quota substitution (`claude-opus-5-5-*` <-> `gemini-4-neon-xhigh` / `gemini-4-carbon-high`) and say so. For a model race, name each arm's exact slug up front (for example `claude-opus-5-5-high`, `gemini-4-neon-xhigh`, `gemini-4-carbon-high`, `gemini-4-hydrogen-high` / `gemini-3.8-flash-high`). Pick each worker's reasoning level for the job, per the Subagents section of the **poteto-mode** skill.
4. Give each worker its own writable output when it writes (`workspace: "share"` or `"branch"`). When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

## Phase B: Fan out

Launch all N workers concurrently using Antigravity's native `swarm` tool (`swarm(action: "add", name: "worker", model: "<slug>", workspace: "share", tasks: [...], brief: ...)` for sharded homogeneous slices, or parallel `swarm(action: "add", name: "<arm>", model: "<slug>", workspace: "share", brief: ...)` calls for per-arm models; or N parallel `invoke_subagent` calls in the same assistant turn with `TypeName: "poteto-agent"` or `"self"` when `Model: "inherit" | "pro" | "flash"` suffices). Homogeneous structured-JSON fan-outs without cross-vendor model pinning can also run via `run_workflow` (`parallel()` + `agent(..., schema=...)`), and `swarm(action: "model", name: "<worker>", model: "<slug>")` switches a waiting worker on quota exhaustion while keeping its context. Use `workspace: "inherit"` only when the worker is strictly read-only or must inspect unbranched local state.

When a worker must start from a non-default pushed branch, instruct the worker to `git fetch origin <branch> && git checkout <branch>` inside its isolated workspace (`workspace: "share"` or `"branch"`).

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Read the terminal results. Drop a result that does not record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap. A gap does not count as a pass. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps. Once all worker results and any commits/artifacts you need are landed or copied out, clean up `swarm` workers with `swarm(action: "kill", name: ...)`.

## Phase D: Report

Return one consolidated in-chat report with a result table, issue one-liners, gaps or dropouts, and the race rule when used.

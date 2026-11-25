---
name: arena
description: "Spawn N parallel candidates at the same task, pick a base, graft the strongest parts of the losers into it. Use for /arena, 'arena this', 'throw it in the arena', or when one attempt at a non-trivial artifact would lock in the wrong shape."
disable-model-invocation: true
---

# Arena

Track one checklist entry per phase (Frame, Fan out, Cross-judge, Pick, Graft, Verify) in `<appDataDir>/brain/<conversation-id>/task.md` before launching anything.

## Phase A: Frame

Every candidate gets the same prompt, so the prompt is the contract.

1. State the artifact each candidate is producing.
2. Derive the rubric, 3-6 concrete gradeable criteria for what success looks like on *this* task. It is the picker's tool in Phase D. Candidates only see the task.
3. Pick the runners. Call `swarm(action: "models", all: true)` first to inspect entitled slugs and live `quotas`. Read the `arena runners` line in `~/.gemini/config/rules/pstack-models.md`, by default `claude-opus-5-5-high`, `gemini-4-carbon-high`, and `gemini-4-neon-xhigh`. Never select or fall back to `gemini-4-argon-*`, `claude-sonnet-5-5-*`, or `gpt-oss-*`. An `auto` or `inherit-parent` entry is the parent model, so omit `model` in `swarm` (or pass `Model: "inherit"` in `invoke_subagent`). If `swarm` rejects a slug, use the nearest valid slug of the same tier or drop the seat, keep at least two runners, and say so. If a family has `quota_remaining: "0%"` or fails with `RESOURCE_EXHAUSTED`, report the quota substitution and map `claude-opus-5-5-*` to `gemini-4-neon-xhigh` / `gemini-4-carbon-high` (or vice versa when `gemini-*` is at `0%`), deduplicating repeated models unless the task is generation-bound. Families go by prefix: `claude-*` (Opus 5.5) and `gemini-*` (Neon `gemini-4-neon-*`, Carbon `gemini-4-carbon-*`, Hydrogen / Flash `gemini-4-hydrogen-*` or `gemini-3.8-flash-*`). Spawn more for multiple design directions, and repeat one model when the work is generation-bound, not judgment-sensitive. Pick each runner's reasoning level per the Subagents section of the **poteto-mode** skill.
4. Give each candidate its own output location (`workspace: "share"` or `"branch"` in `swarm`, `Workspace: "share"` or `"branch"` in `invoke_subagent`, or `/tmp/arena-<slug>/candidate-<n>/`), per the **separate-before-serializing-shared-state** principle skill.

## Phase B: Fan out

Spawn all N candidates in parallel using `swarm(action: "add", name: "arena-<n>", model: "<slug>", workspace: "share", brief: ...)` so each seat runs natively on its exact configured slug (or parallel `invoke_subagent` calls when all seats use `inherit` / `pro` / `flash`, or headless `agy --model <slug> --effort <level> -p='...'` outside the IDE). Give each candidate the task, the path to the shared grounding, its own output path, and instructions to produce the artifact and a short rationale naming the alternatives it considered and what it rejected.

If a candidate produces no output, proceed with N-1 and note the dropout. Do not `swarm(action: "kill")` a candidate whose workspace holds uncommitted candidate files until Phase E grafting and Phase F verification complete!

## Phase C: Cross-judge

After all Phase B candidates complete, spawn one read-only judge (`swarm(action: "add", name: "arena-judge", model: "<slug>", workspace: "inherit", brief: ...)` with strict read-only instructions) from the `arena cross-judge pool` line in `~/.gemini/config/rules/pstack-models.md`, by default `claude-opus-5-5-high`, `gemini-4-neon-xhigh`, and `gemini-4-carbon-high` (never `gemini-4-argon-*`, `claude-sonnet-5-5-*`, or `gpt-oss-*`). The judge is never from the parent's vendor (`claude-*` vs `gemini-*`), so use the first entry from another vendor with positive quota. An `auto` or `inherit-parent` entry is the parent model, so it never judges. If you do not know the parent's model, use the first real entitled slug with quota and say that the vendor check did not run. If `swarm` rejects a slug, use the nearest valid slug of the same tier, then the next entry from another vendor, or skip the judge (for example when the other vendor is at `0%` quota), and say so. While you read in Phase D, the judge scores each candidate, by path label, on each rubric criterion and recommends a base.

## Phase D: Pick a base

Read every candidate end to end before picking. Score each against the rubric criterion by criterion, not on holistic feel, and compare with the cross-judge when Phase C ran one. Agreement on the base confirms the pick. Disagreement means one of you is biased or the rubric was ambiguous. Read both rationales before deciding.

Pick the base a future maintainer can extend most easily without breaking invariants. When two feel tied, prefer the cleaner boundary or smaller API, per the Laziness Protocol.

## Phase E: Graft

Walk each losing candidate once more for what is worth porting into the base, usually one or two things per candidate, not most of it. Fold each graft in by hand, per the **redesign-from-first-principles** principle skill, so the result stays coherent under one mental model. Don't paste mechanically.

If the candidates converge on one shape, that is strong agreement. Note it and ship the consensus shape. No graft is needed. If they wildly diverge, Phase A was under-specified. Reframe and re-run rather than averaging the divergence.

## Phase F: Verify

Verify the synthesized artifact like any other output, per the **prove-it-works** principle skill. Once the synthesized artifact is landed in your working tree and verified, clean up any spawned `swarm` workers with `swarm(action: "kill", name: ...)`. If verification finds a problem the arena missed, either Phase A was wrong (re-frame and re-run) or a candidate caught it and you missed the graft (go back to Phase E). Don't paper over it.

## Outputs

One synthesized artifact, with a short synthesis note alongside naming the base and why, the cross-judge's verdict or that Phase C skipped the judge, each graft with its source candidate, what was rejected and why, any convergence or dropouts, and the verification result.

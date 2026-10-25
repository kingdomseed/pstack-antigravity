# Antigravity runtime and model guide

This package is a native Antigravity conversion of Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack) (`0.15.32`). Every principle skill is unchanged. Host-specific primitives (plugin manifest, subagents, model slugs, rules, worktree isolation, timers, transcripts, and verification surfaces) use native Antigravity tools and paths directly.

## Install and validate

Validate and install the plugin from `/Users/jasonholt/repos/pstack-antigravity`:

```sh
/Users/jasonholt/.local/bin/agy plugin validate /Users/jasonholt/repos/pstack-antigravity/plugins/pstack --strict
/Users/jasonholt/repos/pstack-antigravity/plugins/pstack/scripts/install-antigravity.sh
/Users/jasonholt/.local/bin/agy plugin list
```

`install-antigravity.sh` installs the plugin into `~/.gemini/config/plugins/pstack`, syncs the skills into `~/.gemini/config/skills/` (so both standalone `agy` and T3 Code ACP sessions see every skill in realpath-checked workspaces), and seeds `~/.gemini/config/rules/pstack-models.md` and `~/.gemini/pstack-models.md` from `scripts/pstack-models.default.md` if not already present.

## Subagents (`invoke_subagent`)

Antigravity spawns subagents with `invoke_subagent`:

- `TypeName: "poteto-agent"`: code-writing and helper delegates inside `/poteto-mode` playbooks. Reads `poteto-mode/SKILL.md` in full before any work.
- `TypeName: "comment-sicko"`: comment-deletion and `MUST KILL` flagger used by `/no-comments`.
- `TypeName: "research"`: built-in read-only subagent for exploration and code review (`/how`, `/interrogate`). Note that `research` has `enable_mcp_tools: false`.
- `TypeName: "self"`: built-in subagent that inherits the parent agent's full configuration and MCP access. Use `TypeName: "self"` (with read-only prompt instructions) when a read-only investigator or reviewer needs MCP tools (`/why`, `/reflect`).
- `Workspace: "inherit" | "branch" | "share"`: `inherit` shares the parent working tree; `branch` creates an isolated clone; `share` creates a shared-repo worktree (`git worktree` / `hg share`) so parallel writers (`swarm`, `arena`, `autopilot-full`, `shipping`) never collide.
- Asynchronous wakeup: `invoke_subagent` runs in the background and automatically resumes the parent turn when a message or completion arrives. Never poll `manage_subagents` in a loop. Use `send_message` (`Recipient: "<conversationID>"`) only when state lives inside that subagent.

## Models and cross-family panels

Check entitled models at any time with:

```sh
agy models
```

| Role group | Default model | How Antigravity runs it |
| --- | --- | --- |
| Code workers (`feature, refactoring`, `bug-fix`, `perf-issue`, `hillclimb`, `swarm workers`) | `gemini-4-argon-high` | `invoke_subagent` with `Model: "pro"` (or `"inherit"` when parent is `gemini-4-argon-high`), or `agy -p --model gemini-4-argon-high` |
| Judgment and prose (`judgment and prose`, `hardest tasks`, `how explainer`, `why synthesizer`, `reflect judgment, divergent, synthesizer`) | `claude-opus-5-5-high` | `Model: "inherit"` when parent is Opus, `agy -p --model claude-opus-5-5-high`, or T3 Code `delegate_task` |
| Fast exploration (`how explorer`, `why investigators`, `reflect tooling`) | `gemini-4-argon-high` (or `gemini-3.8-flash-high`) | `invoke_subagent` with `Model: "pro"` or `Model: "flash"` |
| Diverse panels (`arena runners`, `arena cross-judge pool`, `architect runners`, `interrogate reviewers`) | `claude-opus-5-5-high, gemini-4-argon-high` | `gemini-*` seat via `invoke_subagent` (`Model: "pro"`) or `agy -p`; `claude-*` seat via `agy -p --model claude-opus-5-5-high` or T3 Code `delegate_task` |

Run `/setup-pstack` to customize `~/.gemini/config/rules/pstack-models.md` and `~/.gemini/pstack-models.md`.

## Timers, schedules, and sidecars

- In-session loops and heartbeats use the native `schedule` tool:
  - One-shot wakeup: `DurationSeconds` with `TimerCondition: "never" | "any" | "<sender-id>"`.
  - Recurring check: `CronExpression` (5-field cron, such as `"0 * * * *"` for hourly ticks) with `IsDaemon: false` while driving an active task or `IsDaemon: true` for an independent standing job.
- Persistent background automations outside a chat session use `/automation` (`~/.gemini/automations/<name>/automation.toml`).

## Transcripts, rules, and verification

- Session transcripts live at `<appDataDir>/brain/<conversation-id>/.system_generated/logs/transcript.jsonl` (and `transcript_full.jsonl` when `truncated_fields` is present) and `~/.gemini/antigravity-cli/conversations/`.
- Project skills live under `.agents/skills/` (such as `.agents/skills/verify-<app>/SKILL.md`), personal skills under `~/.gemini/config/skills/`, and global rules under `~/.gemini/config/rules/*.md`.
- Live UI verification uses Antigravity's browser/preview tools (`chrome_*` in standalone CLI or `preview_*` in T3 Code), and CLI/TUI verification uses `run_command` and `manage_task`.

# Antigravity runtime and model guide

This package is a native Antigravity conversion of Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack) (`0.15.36`, upstream commit `c742dd61706fbacc1b95f1a20b7b988cf096ce6c`). Every principle skill is unchanged. Host-specific primitives (plugin manifest, native `swarm` board, custom subagents with explicit tool and MCP grants, 5-tier model routing, rules, worktree isolation, timers, transcripts, and verification surfaces) use native Antigravity tools and paths directly.

## Install and validate

Validate and install the plugin from `/Users/jasonholt/repos/pstack-antigravity`:

```sh
/Users/jasonholt/.local/bin/agy plugin validate /Users/jasonholt/repos/pstack-antigravity/plugins/pstack --strict
/Users/jasonholt/repos/pstack-antigravity/plugins/pstack/scripts/install-antigravity.sh
/Users/jasonholt/.local/bin/agy plugin list
```

Pass `--reset-models` to `install-antigravity.sh` when you want to overwrite existing `pstack-models.md` rules with the latest defaults:

```sh
/Users/jasonholt/repos/pstack-antigravity/plugins/pstack/scripts/install-antigravity.sh --reset-models
```

`install-antigravity.sh`:
- Installs the plugin into `~/.gemini/config/plugins/pstack` via `agy plugin install` (and links `~/.t3/userdata/providers/antigravity/*/config/plugins -> ~/.gemini/config/plugins` when T3 Code is present).
- Removes any stale duplicate `pstack` skill folders from `~/.gemini/config/skills/` so pstack slash commands never appear twice in Antigravity, while preserving standalone non-pstack skills (`cua-driver`, `instabox*`).
- Seeds `~/.gemini/config/rules/pstack-models.md`, `~/.gemini/pstack-models.md`, and `~/.t3/userdata/providers/antigravity/*/config/rules/pstack-models.md` from `scripts/pstack-models.default.md`.

## Multi-agent delegation: `swarm` and `invoke_subagent`

Antigravity provides two native multi-agent surfaces. Use the one that matches the job:

### 1. Native `swarm` (exact model slug pinning + live quota inspection)

Use `swarm` whenever a role or panel requires pinning an exact model slug across families (`claude-opus-5-5-high`, `claude-sonnet-5-5-high`, `gemini-4-carbon-high`, `gemini-4-argon-high`, `gemini-4-hydrogen-high` / `gemini-3.8-flash-high`):

- `swarm(action: "models", all: true)` returns every accepted model slug plus live `quotas` (`remaining` percentage and `reset` timestamp) per model family. Call it once before multi-model fan-out (`/arena`, `/architect`, `/interrogate`, `/swarm`, `/why`, `/reflect`).
- `swarm(action: "add", name: "<worker>", model: "<slug>", workspace: "share" | "branch" | "inherit", brief: "...")` spawns a worker pinned to `<slug>` (`tasks: [...]` or `n: <k>` spawns `<name>-1`..`<name>-<k>`). Workers start fresh and see only the public board, so paste full briefs and tell code-writing workers to read `poteto-mode/SKILL.md` first.
- `swarm(action: "model", name: "<worker>", model: "<slug>")` switches a `waiting` worker on quota exhaustion without losing its conversation.
- `swarm(action: "kill", name: "<worker>")` permanently ends a worker and deletes its `share` or `branch` workspace. Land or cherry-pick a worker's commits before killing it, then kill finished workers when the round closes.

### 2. `invoke_subagent` (custom subagent prompts + built-in specialist agents)

Use `invoke_subagent` (`Model: "inherit" | "pro" | "flash" | "flash_lite"`, `Workspace: "inherit" | "branch" | "share"`) when the worker's system prompt or specialist toolset matters and `Model` covers the target tier:

- `TypeName: "poteto-agent"`: code-writing and helper delegates inside `/poteto-mode` playbooks. Configured in `agents/poteto-agent.md` with full write, command, task, subagent, `swarm`, and MCP grants (`inheritMcp: true`, `inheritCustomizations: true`). Reads `poteto-mode/SKILL.md` in full before any work.
- `TypeName: "comment-sicko"`: comment-deletion and `MUST KILL` flagger used by `/no-comments`, configured with `edit_file`, `run_command`, and MCP inheritance.
- `TypeName: "research"`: built-in read-only subagent for fast codebase exploration (`/how`). Note that `research` runs without MCP or network access.
- `TypeName: "self"`: built-in subagent inheriting the parent agent's full configuration and MCP access. Use `TypeName: "self"` (with read-only prompt instructions) when a read-only investigator needs MCP tools (`/why`, `/reflect`).
- `TypeName: "browser"`: built-in webview browser agent (`Model: "flash"` by default) for live web UI verification alongside `chrome-devtools` / `browse` MCP and `cua-driver`.
- Parallelism and wakeup: launch parallel subagents via multiple `invoke_subagent` tool calls in the same assistant turn. Both `swarm` and `invoke_subagent` wake the parent turn reactively on completion; never poll in a loop.

### 3. Headless CLI and T3 Code fallbacks

When running a one-shot cross-family invocation outside `swarm`, always pass `--model` before `-p` or use `-p='...'` (`-p` takes the next token as its prompt):

```sh
agy --model claude-opus-5-5-high --effort high -p='<prompt>'
```

In T3 Code ACP sessions, `delegate_task` also accepts exact cross-family slugs directly.

## Antigravity 5-tier model catalog and `gpt-oss-*` exclusion

Antigravity pstack routes work across five frontier model tiers:

1. **Gemini 4 Carbon** (`gemini-4-carbon-{low,medium,high}`): deepest Gemini reasoning tier for root-cause debugging, performance investigation, hillclimbing, and cross-family panels.
2. **Gemini 4 Argon** (`gemini-4-argon-{low,medium,high}`): balanced daily workhorse for features, refactoring, and parallel swarm lanes (`Model: "pro"` in `invoke_subagent`).
3. **Hydrogen / Gemini Flash** (`gemini-4-hydrogen-{low,medium,high}` when exposed in `swarm(action: "models", all: true)` / `agy models`, currently served as `gemini-3.8-flash-{low,medium,high}` / `Model: "flash"`): high-speed exploration, MCP archaeology, and transcript preflight.
4. **Claude Opus 5.5** (`claude-opus-5-5-{low,medium,high}`): judgment, prose, synthesis, hardest tasks, and cross-family panels.
5. **Claude Sonnet 5.5** (`claude-sonnet-5-5-{low,medium,high}`): fast Anthropic runner for 3-seat design and code arenas (`/arena`, `/architect`) and medium-budget Anthropic roles.

**Hard exclusion (`gpt-oss-*`):** Never detect, offer, configure, or fall back to `gpt-oss-*` (`gpt-oss-120b-medium`).

**Live quota fallback:** Before spawning a `claude-*` worker, check `quotas` from `swarm(action: "models", all: true)`. When a family's remaining quota is `0%` (or a spawn returns `RESOURCE_EXHAUSTED`), substitute `gemini-4-carbon-high` for `claude-opus-5-5-*` and `gemini-4-argon-high` for `claude-sonnet-5-5-*` (or vice versa when Gemini quota is `0%`), and state the substitution in your reply.

| Role group | Default model | Primary Antigravity runner |
| --- | --- | --- |
| Feature, refactoring, swarm lanes (`feature, refactoring`, `swarm workers`) | `gemini-4-argon-high` | `invoke_subagent` (`TypeName: "poteto-agent"`, `Model: "pro"`) or `swarm(action: "add", model: "gemini-4-argon-high", ...)` |
| Deep debugging & perf (`bug-fix`, `perf-issue`, `hillclimb`) | `gemini-4-carbon-high` | `swarm(action: "add", model: "gemini-4-carbon-high", ...)` (or `invoke_subagent` `Model: "inherit"` when parent is Carbon) |
| Judgment, prose, synthesis (`judgment and prose`, `hardest tasks`, `how explainer`, `why synthesizer`, `reflect judgment, divergent, synthesizer`) | `claude-opus-5-5-high` | `swarm(action: "add", model: "claude-opus-5-5-high", ...)` (or `Model: "inherit"` when parent is Opus; quota fallback `gemini-4-carbon-high`) |
| Fast exploration & archaeology (`how explorer`, `why investigators`, `reflect tooling`) | `gemini-3.8-flash-high` (`gemini-4-hydrogen-high` when listed) | `invoke_subagent` (`Model: "flash"`) or `swarm(action: "add", model: "gemini-3.8-flash-high", ...)` |
| Design & code panels (`arena runners`, `architect runners`) | `claude-opus-5-5-high, gemini-4-carbon-high, claude-sonnet-5-5-high` | `swarm(action: "add", ...)` per seat in isolated `workspace: "share"` |
| Cross-judge & adversarial review (`arena cross-judge pool`, `interrogate reviewers`) | `claude-opus-5-5-high, gemini-4-carbon-high[, gemini-4-argon-high]` | `swarm(action: "add", ...)` on a family disjoint from the author/candidate |

Run `/setup-pstack` to customize `~/.gemini/config/rules/pstack-models.md` and `~/.gemini/pstack-models.md`.

## Timers, artifacts, MCP schemas, and verification

- **Task checklist:** `/poteto-mode` writes playbook checklists to `<appDataDir>/brain/<conversation-id>/task.md` (`write_file` / `edit_file` with `ArtifactMetadata`) and decision trails to `decisions.tsv` or `<appDataDir>/brain/<conversation-id>/decisions.tsv`.
- **Timers and schedules:** In-session loops and heartbeats use `schedule` (`DurationSeconds` with `TimerCondition` for one-shot wakeups; 5-field `CronExpression` with `IsDaemon: false | true` for recurring checks). Persistent background automations outside a chat session use `/automation` (`~/.gemini/automations/<name>/automation.toml`).
- **MCP schemas:** Lazy MCP server tool schemas live at `<appDataDir>/mcp/<serverName>/<toolName>.json` (for example `~/.gemini/antigravity/mcp/<serverName>/`).
- **Session transcripts:** `<appDataDir>/brain/<conversation-id>/.system_generated/logs/transcript.jsonl` (and `transcript_full.jsonl` when `truncated_fields` is present) plus `~/.gemini/antigravity-cli/conversations/`.
- **Live verification:** Web UIs use `.agents/skills/verify-<app>/`, `invoke_subagent` (`TypeName: "browser"`), `chrome-devtools` / `browse` MCP, or `chrome_*` / `preview_*`. Native desktop apps use `cua-driver` or `.agents/skills/verify-<app>/`. Mobile apps use Patrol / Marionette / simulator skills. CLIs and TUIs use `run_command` and `manage_task`.

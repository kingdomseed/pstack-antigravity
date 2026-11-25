# Antigravity runtime and model guide

This package is a native Antigravity conversion of Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack) (`0.15.48`, upstream commit `9e278fe4d41f5e6e0c93a9df4b0de5a1d9ef6d4a`). Every principle skill keeps its rule and test verbatim. Host-specific primitives (plugin manifest, native `swarm` board, custom subagents with explicit tool and MCP grants, 4-tier model routing, rules, worktree isolation, timers, transcripts, and verification surfaces) use native Antigravity tools and paths directly.

## Install and validate

Validate and install the plugin from a local checkout root (or directly from `https://github.com/kingdomseed/pstack-antigravity`):

```sh
agy plugin validate ./plugins/pstack --strict
./plugins/pstack/scripts/install-antigravity.sh
agy plugin list
```

Pass `--reset-models` to `install-antigravity.sh` when you want to overwrite existing `pstack-models.md` rules with the latest defaults:

```sh
./plugins/pstack/scripts/install-antigravity.sh --reset-models
```

`install-antigravity.sh`:
- Installs the plugin into `~/.gemini/config/plugins/pstack` via `agy plugin install` (and links `~/.t3/userdata/providers/antigravity/*/config/plugins -> ~/.gemini/config/plugins` when T3 Code is present).
- Removes any stale duplicate `pstack` skill folders from `~/.gemini/config/skills/` so pstack slash commands never appear twice in Antigravity, while preserving standalone non-pstack skills (`cua-driver`, `instabox*`).
- Seeds `~/.gemini/config/rules/pstack-models.md`, `~/.gemini/pstack-models.md`, and `~/.t3/userdata/providers/antigravity/*/config/rules/pstack-models.md` from `scripts/pstack-models.default.md`.

## Multi-agent delegation: `swarm`, `run_workflow`, and `invoke_subagent`

Antigravity provides three native multi-agent surfaces. Use the one that matches the job:

### 1. Native `swarm` (shared board + exact model slug pinning + live quota inspection)

Use `swarm` whenever a role or panel requires pinning an exact model slug across vendors (`claude-opus-5-5-high`, `gemini-4-neon-xhigh`, `gemini-4-neon-high`, `gemini-4-carbon-high`, `gemini-4-hydrogen-high` / `gemini-3.8-flash-high`), or when workers need to coordinate on a shared board:

- `swarm(action: "models", all: true)` returns every accepted model slug plus live `quotas` (`remaining` percentage and `reset` timestamp) per model family. Call it once before multi-model fan-out (`/arena`, `/interrogate`, `/swarm`).
- `swarm(action: "add", name: "<worker>", model: "<slug>", workspace: "share" | "branch" | "inherit", brief: "...")` spawns a worker pinned to `<slug>` (`tasks: [...]` or `n: <k>` spawns `<name>-1`..`<name>-<k>`; pass `fork: "<member>"` when a worker needs another member's conversation history). Workers start fresh and see only the public board by default, so paste full briefs, open with `Read <path>/worker.md before anything else.`, and tell code-writing workers to read `poteto-mode/SKILL.md` first.
- Board messaging tools (`post_message`, `read_board`, `swarm_wait`) appear on the turn *after* the first `swarm(action: "add")` call.
- `swarm(action: "model", name: "<worker>", model: "<slug>")` switches a `waiting` worker on quota exhaustion without losing its conversation.
- `swarm(action: "kill", name: "<worker>")` permanently ends a worker and deletes its `share` or `branch` workspace. Land or cherry-pick a worker's commits before killing it, then kill finished workers when the round closes.

### 2. `run_workflow` (Dynamic Workflows — Python orchestration + JSON schemas)

Use `run_workflow` (`/run-workflow`, bundled Python with no external install required) for structured multi-item fan-outs (per-file audits, coverage sweeps, transcript slicing, evals) or staged multi-step pipelines where deterministic control flow, JSON-schema outputs, and keeping bulk out of the main thread matter more than exact cross-vendor model pinning:

- Primitives include `parallel()`, `pipeline()`, `phase()`, `agent(prompt, schema=..., role=..., type_name=..., workspace="inherit" | "branch" | "share", model="inherit" | "flash_lite" | "flash" | "pro")`, `call_tool()`, and `trajectory(...)` for transcript inspection.
- Workflow agents keep their own conversations and return typed JSON matching `schema`; bulk file reads and logs never enter the main chat context.

### 3. `invoke_subagent` (custom subagent prompts + built-in specialist agents)

Use `invoke_subagent` (`Model: "inherit" | "pro" | "flash" | "flash_lite"`, `Workspace: "inherit" | "branch" | "share"`) when a single or small set of delegates needs a custom system prompt or specialist toolset and `Model` covers the target tier:

- `TypeName: "poteto-agent"`: code-writing and helper delegates inside `/poteto-mode` playbooks. Configured in `agents/poteto-agent.md` (`model: inherit`, `mainAgent: false`, `subagent: true`) with `inheritMcp: true` and `inheritCustomizations: true` (omits `tools:` so it inherits the host's full built-in toolset across App, CLI, and IDE without unmapped-tool hangs). Reads `poteto-mode/SKILL.md` in full before any work.
- `TypeName: "comment-sicko"`: comment-deletion and `MUST KILL` flagger used by `/no-comments`, configured with `mainAgent: false`, `subagent: true`, and full MCP/customization inheritance.
- `TypeName: "research"`: built-in read-only subagent for fast codebase exploration (`/how`). Note that `research` runs without MCP or network access.
- `TypeName: "self"`: built-in subagent inheriting the parent agent's full configuration and MCP access. Use `TypeName: "self"` (with read-only prompt instructions) when a read-only investigator needs MCP tools (`/recall`).
- `TypeName: "browser"`: built-in webview browser agent (`Model: "flash"` by default) supporting parallel tabs and native `.mp4` screen recordings for live web UI verification alongside `chrome-devtools` / `browse` MCP and `cua-driver`.
- Parallelism and wakeup: launch parallel subagents via multiple `invoke_subagent` tool calls in the same assistant turn. `swarm`, `run_workflow`, and `invoke_subagent` all wake the parent turn reactively on completion; never poll in a loop.

### 4. Headless CLI and T3 Code fallbacks

When running a one-shot cross-family invocation outside `swarm`, always pass `--model` before `-p` or use `-p='...'` (`-p` takes the next token as its prompt):

```sh
agy --model claude-opus-5-5-high --effort high -p='<prompt>'
```

In T3 Code ACP sessions, `delegate_task` also accepts exact cross-family slugs directly.

## Antigravity 4-tier model catalog and exclusions

Antigravity pstack routes work across four allowed frontier model tiers across two vendors, capped at `xhigh`:

1. **Claude Opus 5.5** (`claude-opus-5-5-{low,medium,high}`): judgment, cross-vendor panels, and adversarial review. Tops out at `high` in Antigravity.
2. **Gemini 4 Neon** (`gemini-4-neon-{low,medium,high,xhigh}`): primary implementation, refactoring, judgment/prose (`gemini-4-neon-xhigh`), swarm lanes (`gemini-4-neon-high`), and Neon panel seats (`gemini-4-neon-xhigh`).
3. **Gemini 4 Carbon** (`gemini-4-carbon-{low,medium,high}`): deep Gemini reasoning tier for root-cause debugging, performance investigation, hillclimbing, and cross-vendor panels. Tops out at `high` in Antigravity.
4. **Gemini 4 Hydrogen / Flash** (`gemini-4-hydrogen-{low,medium,high,xhigh}`, fallback `gemini-3.8-flash-{low,medium,high}`): high-speed exploration and lightweight helper/eval-dispatch tasks (`Model: "flash"`).

**Hard exclusions:** Never detect, offer, configure, or fall back to `gemini-4-argon-*`, `claude-sonnet-5-5-*`, or `gpt-oss-*` (`gpt-oss-120b-medium`).

**Live quota fallback:** Before spawning a `claude-*` worker, check `quotas` from `swarm(action: "models", all: true)`. When a family's remaining quota is `0%` (or a spawn returns `RESOURCE_EXHAUSTED`), substitute `gemini-4-neon-xhigh` / `gemini-4-carbon-high` for `claude-opus-5-5-*` (or vice versa when `gemini-*` quota is `0%`), deduplicating repeated panel seats, and state the substitution in your reply.

| Role group | Default model | Primary Antigravity runner |
| --- | --- | --- |
| Feature, refactoring, judgment, prose (`feature, refactoring`, `judgment and prose`) | `gemini-4-neon-xhigh` | `swarm(action: "add", model: "gemini-4-neon-xhigh", ...)` or `invoke_subagent` (`TypeName: "poteto-agent"`, `Model: "pro"`) |
| Deep debugging & perf (`bug-fix`, `perf-issue`, `hillclimb`) | `gemini-4-carbon-high` | `swarm(action: "add", model: "gemini-4-carbon-high", ...)` (or `invoke_subagent` `Model: "inherit"` when parent is Carbon) |
| Swarm lanes & mechanical verification (`swarm workers`) | `gemini-4-neon-high` | `swarm(action: "add", model: "gemini-4-neon-high", ...)` or `invoke_subagent` (`TypeName: "poteto-agent"`, `Model: "pro"`) |
| Design & code panels (`arena runners`, `interrogate reviewers`) | `claude-opus-5-5-high, gemini-4-carbon-high, gemini-4-neon-xhigh` | `swarm(action: "add", ...)` per seat in isolated `workspace: "share"` |
| Cross-judge (`arena cross-judge pool`) | `claude-opus-5-5-high, gemini-4-neon-xhigh, gemini-4-carbon-high` | `swarm(action: "add", ...)` on a vendor disjoint from the parent (`claude-*` vs `gemini-*`) |

Run `/setup-pstack` to customize `~/.gemini/config/rules/pstack-models.md` and `~/.gemini/pstack-models.md`.

## Runtime primitives, continuity, and verification

- **Live checklist and status:** Default to `update_steps` (live checklist rendered above the prompt in CLI and in the App) and `update_focus` for in-session progress; write `<appDataDir>/brain/<conversation-id>/task.md` (`write_file` / `edit_file` with `ArtifactMetadata`) only when a persistent multi-session checklist artifact is needed. Decision trails stay at `decisions.tsv` or `<appDataDir>/brain/<conversation-id>/decisions.tsv`.
- **Timers, daemons, and scheduled sidecars:** In-session waits use `schedule` (`DurationSeconds` with `TimerCondition` for one-shot wakeups; 5-field `CronExpression` with `IsDaemon: false | true` for recurring checks). Long-running dev servers use `run_command` with `IsDaemon: true`, and long finite commands/watchers use `NotificationTimeoutSeconds` instead of polling loops. Persistent recurring automations outside a chat session use `/automation` sidecars (`~/.gemini/config/sidecars/<slug>/sidecar.json` with `"builtin": "schedule"`, enabled in `~/.gemini/config/config.json`, and managed at `sidecar://dashboard`).
- **Remote execution and continuity:** Local runs keep unlimited local conversation history and auto-resume after App restarts. Use **Remote Control** (`agy remote-control`) to monitor and steer local checkouts from phone or browser; **SSH Host projects** (`(SSH: <host>)`) to run the App against a remote Linux machine; and **Remote Agents** (`agy --remote-agent` or New Remote Project on `antigravity.google.com`) for Google-managed cloud runs that keep working while your laptop sleeps.
- **Conversations API, transcripts, and MCP schemas:** When `$ANTIGRAVITY_LS_ADDRESS` is set, query `http://$ANTIGRAVITY_LS_ADDRESS/product.v1.ConversationService/{ListConversations,GetConversation,CreateConversation,UpdateConversation}` for programmatic chat/pinned state instead of scanning the sidebar manually. Transcripts live at `<appDataDir>/brain/<conversation-id>/.system_generated/logs/transcript.jsonl` (and `transcript_full.jsonl` when `truncated_fields` is present) plus `~/.gemini/antigravity-cli/conversations/`. Lazy MCP tool schemas live at `<appDataDir>/mcp/<serverName>/<toolName>.json`.
- **Live verification:** Match the verification surface to the task using the browser/DevTools/computer-use matrix below, `.agents/skills/verify-<app>/`, or `run_command` (`IsDaemon` / `NotificationTimeoutSeconds`) + `manage_task` for CLIs/TUIs.
- **Built-in commands, hooks, and skill paths:** pstack composes directly with Antigravity built-ins (`/plan`, `/compact`, `/btw` parallel side-questions, `/diff` and the VCS Review pane, GitHub PR pills, `/fork`, `/resume`, `/run-workflow`, `/automation`, and `hooks.json` lifecycle hooks). Both `~/.gemini/config/skills/` and `~/.agents/skills/` are discovered globally alongside plugin skills.

## Browser, DevTools, and computer-use surfaces

| Surface | Best for | Strengths and constraints |
| --- | --- | --- |
| **Built-in `browser` subagent** (`TypeName: "browser"`, `Model: "flash"`, App `v2.30.0+` personal accounts) | Fast UI flows and multi-page visual sweeps | Zero Chrome setup; parallel isolated tabs; live cursor and one-click **Stop** takeover; persistent per-account cookie profile with sign-in handoff; `localhost:port` isolation; console + sanitized network + screenshots/snapshots. Does not run arbitrary `evaluate_script` or DevTools profiling. |
| **`chrome-devtools` MCP** (`chrome-devtools-plugin` / `chrome-devtools-mcp`, also backing CLI/IDE `/browser` via `chrome://inspect/#remote-debugging`) | Web `Perf issue`, `Trace forensics`, `Runtime forensics`, auth & extension debugging | Performance traces, LCP/Core Web Vitals, heap snapshots (`--memoryDebugging`), extension debugging (`--categoryExtensions`), Lighthouse audits, `get_css_styles`, `evaluate_script`, MP4 session recordings (CLI `1.5.9+`), logpoints (`set_logpoints`), virtual WebAuthn authenticators (`configure_webauthn`), and page-scoped network mocks. |
| **Anomaly's `browse` MCP** (`anomalyco/browse`, `@opencode/browse`) | Real signed-in Chromium-family tabs, visual diffing, 2FA handoffs, WebMCP | Drives your real browser via collapsed background tab groups (no focus theft) and user-lent tabs with `allowedOrigins` scoping. Playwright-style `execute` scripts (`page`, persistent `state`), `snapshot()`/`ref()`, `screenshotWithLabels()`, built-in `screenshotDiff({baseline})`, tab `recording`, `network` and `pageConsole` capture, `webmcp.list/call`, `handoff()` (login/2FA/payment), and `demonstrate()` (watch the user perform a flow). |
| **`cua-driver` & mobile tooling** (`flutter_dart-mcp-server`, Patrol, simulators) | Native desktop and mobile UIs | `cua-driver` drives desktop accessibility trees plus screenshots and pixel actions; Flutter/mobile tooling handles widget inspection and simulator runs. |
| **Gemini Computer Use API & WebMCP** | Custom visual test harnesses and WebMCP-enabled apps | In standalone `google-genai` harnesses, Gemini 4 `computer_use` (`environment: "browser" \| "mobile" \| "desktop"`) outputs structured action `intent` fields, safety policies, and prompt-injection checks over a Playwright/VM executor. When a page exposes WebMCP (`document.modelContext`), prefer structured client-side tools over blind DOM clicking. |

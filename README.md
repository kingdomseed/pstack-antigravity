# pstack for Antigravity

Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack), converted natively to Antigravity from upstream `0.15.36` (`c742dd61706fbacc1b95f1a20b7b988cf096ce6c`).

Upstream license: MIT, Copyright (c) 2026 Lauren Tan.

## What you get

- All 59 pstack skills (`/poteto-mode`, `/setup-pstack`, `/deslop`, `/how`, `/why`, `/arena`, `/architect`, `/swarm`, `/interrogate`, `/no-comments`, `/ketchup`, `/ketchup-video`, `/statechart`, `/reflect`, `/recall`, `/correct`, `/teach`, `/sharpen`, `/in-your-own-words`, and all 24 `principle-*` skills untouched in substance)
- All 23 `/poteto-mode` playbooks adapted directly to Antigravity's native tools (`swarm`, `invoke_subagent`, `send_message`, `manage_subagents`, `schedule`, `ask_question`, `run_command`, `manage_task`, `TypeName: "browser"`, `cua-driver`, `chrome_*` / `preview_*`)
- Plugin-owned custom subagents (`poteto-agent` and `comment-sicko`) in `plugins/pstack/agents/` with explicit write, command, subagent, `swarm`, and MCP inheritance grants
- 5-tier cross-family model role map across **Gemini 4 Carbon** (`gemini-4-carbon-high`), **Gemini 4 Argon** (`gemini-4-argon-high`), **Hydrogen / Gemini Flash** (`gemini-3.8-flash-high` / `gemini-4-hydrogen-high`), **Claude Opus 5.5** (`claude-opus-5-5-high`), and **Claude Sonnet 5.5** (`claude-sonnet-5-5-high`) with **`gpt-oss-*` strictly excluded** and live quota fallback via `swarm(action: "models", all: true)` at `plugins/pstack/scripts/pstack-models.default.md`, configurable via `/setup-pstack` in `~/.gemini/config/rules/pstack-models.md` and `~/.gemini/pstack-models.md`

## Install

```bash
/Users/jasonholt/repos/pstack-antigravity/plugins/pstack/scripts/install-antigravity.sh
```

Pass `--reset-models` to overwrite existing `pstack-models.md` rule files with the latest defaults:

```bash
/Users/jasonholt/repos/pstack-antigravity/plugins/pstack/scripts/install-antigravity.sh --reset-models
```

Or validate and install directly with the Antigravity CLI:

```bash
/Users/jasonholt/.local/bin/agy plugin validate /Users/jasonholt/repos/pstack-antigravity/plugins/pstack --strict
/Users/jasonholt/.local/bin/agy plugin install /Users/jasonholt/repos/pstack-antigravity/plugins/pstack
/Users/jasonholt/.local/bin/agy plugin list
```

Install the locked dependencies for the bundled TypeScript PR watcher and plan validator:

```bash
cd /Users/jasonholt/repos/pstack-antigravity/plugins/pstack/skills/poteto-mode/scripts
bun install --frozen-lockfile
```

## Use

```text
/poteto-mode this test flakes every ~12 runs. repro, root-cause, fix, verify.
/setup-pstack
/how does cancellation work?
/deslop
/interrogate review this diff.
```

Read the [package README](./plugins/pstack/README.md) and the [Antigravity runtime and model guide](./plugins/pstack/docs/guide/00-antigravity.md).

## Validate

- Plugin manifest, agents, and all 59 skills: `agy plugin validate /Users/jasonholt/repos/pstack-antigravity/plugins/pstack --strict --json`
- Bundled TypeScript tools (`watch-pr`, `check-plan`): `bun test && bun run typecheck` from `plugins/pstack/skills/poteto-mode/scripts/`
- Statechart compiler & TLA+ tests: `npm test` from `plugins/pstack/skills/statechart/scripts/`

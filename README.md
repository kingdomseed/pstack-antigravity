# pstack for Antigravity

Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack), converted natively to Antigravity from upstream `0.15.48` (`9e278fe4d41f5e6e0c93a9df4b0de5a1d9ef6d4a`).

Upstream license: MIT, Copyright (c) 2026 Lauren Tan.

## What you get

- All 60 pstack skills (`/poteto-mode`, `/setup-pstack`, `/deslop`, `/reframe`, `/how`, `/why`, `/arena`, `/architect`, `/swarm`, `/interrogate`, `/no-comments`, `/ketchup`, `/ketchup-video`, `/statechart`, `/reflect`, `/recall`, `/correct`, `/teach`, `/sharpen`, `/in-your-own-words`, and all 24 `principle-*` skills untouched in substance)
- All 22 `/poteto-mode` playbooks adapted directly to Antigravity's native tools (`swarm`, `run_workflow`, `invoke_subagent`, `update_steps`, `update_focus`, `send_message`, `manage_subagents`, `schedule`, `ask_question`, `run_command`, `manage_task`, `TypeName: "browser"`, `chrome-devtools` / `browse` MCP, `cua-driver`)
- Plugin-owned custom subagents (`poteto-agent` and `comment-sicko`) in `plugins/pstack/agents/` (`mainAgent: false`, `subagent: true`, `inheritMcp: true`, `inheritCustomizations: true`, inheriting the host's full built-in toolset)
- 4-tier cross-vendor model role map across **Claude Opus 5.5** (`claude-opus-5-5-high`), **Gemini 4 Neon** (`gemini-4-neon-xhigh` / `-high`), **Gemini 4 Carbon** (`gemini-4-carbon-high`), and **Gemini 4 Hydrogen / Flash** (`gemini-4-hydrogen-high` / `gemini-3.8-flash-high`), with **`gemini-4-argon-*`, `claude-sonnet-5-5-*`, and `gpt-oss-*` strictly excluded** and live quota fallback via `swarm(action: "models", all: true)` at `plugins/pstack/scripts/pstack-models.default.md`, configurable via `/setup-pstack` in `~/.gemini/config/rules/pstack-models.md` and `~/.gemini/pstack-models.md`

## Install

From the repository root:

```bash
./plugins/pstack/scripts/install-antigravity.sh
```

Pass `--reset-models` to overwrite existing `pstack-models.md` rule files with the latest defaults:

```bash
./plugins/pstack/scripts/install-antigravity.sh --reset-models
```

Or validate and install directly with the Antigravity CLI (or install from GitHub):

```bash
agy plugin validate ./plugins/pstack --strict
agy plugin install ./plugins/pstack
# or: agy plugin install https://github.com/kingdomseed/pstack-antigravity
agy plugin list
```

Install the locked dependencies for the bundled TypeScript PR watcher:

```bash
cd plugins/pstack/skills/poteto-mode/scripts
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

- Plugin manifest, agents, and all 60 skills: `agy plugin validate ./plugins/pstack --strict --json`
- Bundled TypeScript tools (`watch-pr`): `bun test && bun run typecheck` from `plugins/pstack/skills/poteto-mode/scripts/`
- Statechart compiler & TLA+ tests: `npm test` from `plugins/pstack/skills/statechart/scripts/`

# pstack for Antigravity

Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack), converted natively to Antigravity from upstream `0.15.32` (`99b609a72323b70204eab407c622f436e858e112`).

Upstream license: MIT, Copyright (c) 2026 Lauren Tan.

## What you get

- All 59 pstack skills (`/poteto-mode`, `/setup-pstack`, `/deslop`, `/how`, `/why`, `/arena`, `/architect`, `/swarm`, `/interrogate`, `/no-comments`, `/ketchup`, `/ketchup-video`, `/statechart`, `/reflect`, `/recall`, `/correct`, `/teach`, `/sharpen`, `/in-your-own-words`, and all 24 `principle-*` skills untouched in substance)
- All 23 `/poteto-mode` playbooks adapted directly to Antigravity's native tools (`invoke_subagent`, `send_message`, `manage_subagents`, `schedule`, `ask_question`, `run_command`, `manage_task`, `chrome_*` / `preview_*`)
- Plugin-owned custom subagents (`poteto-agent` and `comment-sicko`) in `plugins/pstack/agents/`
- Default cross-family model role map (`gemini-4-argon-high` for code workers and `claude-opus-5-5-high` for prose and judgment, with `claude-opus-5-5-high, gemini-4-argon-high` on multi-model panels) at `plugins/pstack/scripts/pstack-models.default.md`, configurable via `/setup-pstack` in `~/.gemini/config/rules/pstack-models.md` and `~/.gemini/pstack-models.md`

## Install

```bash
/Users/jasonholt/repos/pstack-antigravity/plugins/pstack/scripts/install-antigravity.sh
```

Or validate and install directly with the Antigravity CLI:

```bash
/Users/jasonholt/.local/bin/agy plugin validate /Users/jasonholt/repos/pstack-antigravity/plugins/pstack --strict
/Users/jasonholt/.local/bin/agy plugin install /Users/jasonholt/repos/pstack-antigravity/plugins/pstack
/Users/jasonholt/.local/bin/agy plugin list
```

Install the locked dependencies for the bundled TypeScript PR watcher and orchestration tools:

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
- Bundled TypeScript tools (`orch`, `watch-pr`, `check-plan`): `bun test` from `plugins/pstack/skills/poteto-mode/scripts/`
- Statechart & Pele renderer tests: `node --test scripts/test/statechart.test.mjs` from `plugins/pstack/skills/statechart/`

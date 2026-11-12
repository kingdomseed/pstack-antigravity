---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## 1. Locate the active transcript

Before fanning out, find this conversation's transcript at `<appDataDir>/brain/<conversation-id>/.system_generated/logs/transcript.jsonl` (or `transcript_full.jsonl` when `truncated_fields` is present), as named in your `<conversation_transcript>` system prompt, or in `~/.gemini/antigravity-cli/conversations/` for standalone CLI sessions. Do not glob across unrelated workspaces or private chats from other projects.

```bash
ls -t "<appDataDir>/brain/<conversation-id>/.system_generated/logs/transcript.jsonl" ~/.gemini/antigravity-cli/conversations/*.json* 2>/dev/null | head -10
```

Start with `transcript.jsonl`. Read the `USER_INPUT` steps to verify the file matches the current conversation's opening user prompt. If no transcript file is accessible, pass a tight digest of the session instead.

## 2. Spawn three reviewers in parallel

Check `swarm(action: "models", all: true)` first, then launch all three reviewers in parallel in the same assistant turn (`swarm(action: "add", model: "<slug>", workspace: "inherit", ...)` for exact cross-family slugs, or `invoke_subagent` with `TypeName: "self"`, never `TypeName: "research"` because reviewers need MCP access via `call_mcp_tool` to look up tickets, chat threads, and observability traces the transcript references, and `research` disables MCP tools).

Each reviewer and the synthesizer name a role line in `~/.gemini/config/rules/pstack-models.md` and a default. Never select or fall back to `gpt-oss-*`. Use `Model: "inherit"` (or omit `model` in `swarm`) when the value is `auto` or `inherit-parent`. If `claude-*` quota is `0%`, apply poteto-mode's quota substitution (`claude-opus-5-5-*` -> `gemini-4-carbon-high`) and note it. Pick each reviewer's reasoning level for the job, per the Subagents section of the **poteto-mode** skill.

| Lens | Role line | Default model | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `claude-opus-5-5-high` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `gemini-3.8-flash-high` (`gemini-4-hydrogen-high` when entitled) | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `claude-opus-5-5-high` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in their response body.

## 3. Synthesize

Spawn one synthesizer (`swarm(action: "add", model: "<slug>", workspace: "inherit", ...)` or `invoke_subagent` with `TypeName: "self"`, model from the `reflect judgment, divergent, synthesizer` line, default `claude-opus-5-5-high`). It spot-verifies citations through MCP. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list. Clean up any `swarm` workers with `swarm(action: "kill", name: ...)` once synthesis completes.

## 4. Structural enforcement check

Move any Accepted item that a lint rule, script, metadata flag, or runtime check would enforce more reliably to Backlog. See the **encode-lessons-in-structure** principle skill.

## 5. Apply

Present the synthesizer's full Accepted / Rejected / Backlog output and wait for explicit approval before applying any Accepted edit. The user picks the subset and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

File each Backlog item to your team's devex or backlog tracker without waiting. Only the Accepted list waits for approval.

Never edit an installed plugin cache directly without showing the destination first: `.agents/skills/<skill>/` or `~/.gemini/config/skills/<skill>/` (or the source plugin repository when explicitly maintaining pstack). After approval, copy the skill folder to `.agents/skills/<skill>/` or `~/.gemini/config/skills/<skill>/` and edit the copy. Never open a PR or push without approval.

Follow each approved row's Routing exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): the parent does it directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): draft, test, and iterate on the skill structure and apply `/unslop`.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): refine its `description` frontmatter scalar for trigger accuracy.
- `new skill: <kebab-name>`: author `<kebab-name>/SKILL.md` with valid frontmatter (`name`, `description`, `disable-model-invocation: true` when appropriate) and apply `/unslop`.

Run `agy plugin validate --strict` on the plugin or verify the touched `SKILL.md` frontmatter before declaring done.

## 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.

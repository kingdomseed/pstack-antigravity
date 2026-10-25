# Set up pstack

In this page you install the plugin, pick which models pstack uses, and run your first task. Setup is one command plus a short conversation.

## Install the plugin

From your local `pstack-antigravity` checkout, run:

```bash
/Users/jasonholt/repos/pstack-antigravity/plugins/pstack/scripts/install-antigravity.sh
```

Or install directly with the Antigravity CLI:

```bash
agy plugin install /Users/jasonholt/repos/pstack-antigravity/plugins/pstack
```

Antigravity installs the plugin into `~/.gemini/config/plugins/pstack` and registers its skills and custom subagents (`poteto-agent` and `comment-sicko`). See the [Antigravity runtime and model guide](./00-antigravity.md) for T3 Code and CLI details.

## Pick your models with `/setup-pstack`

Run:

```text
/setup-pstack
```

[`/setup-pstack`](../../skills/setup-pstack/SKILL.md) detects the models you have access to via `agy models`, asks for a reasoning budget, shows you each role (code delegates, judgment, the review panels), and asks what you want. Answer the questions. It writes `~/.gemini/config/rules/pstack-models.md` (and `~/.gemini/pstack-models.md`), a small always-on rule every pstack skill reads.

The defaults use `gemini-4-argon-high` for code roles and `claude-opus-5-5-high` for judgment and prose, with both `claude-opus-5-5-high` and `gemini-4-argon-high` on multi-model panels. `unlimited` and `large` keep the `-high` model slugs and record `max` or `xhigh` effort for CLI runs. `small` lowers the slugs to `-medium` and spends fewer tokens.

To keep every role on your active session model, set the roles you want to `auto` or `inherit-parent`.

## Optional: generate a verification skill

At the end of setup, `/setup-pstack` looks for a way to prove app behavior in your project, either a `verify-*` skill under `.agents/skills/` or an existing harness. If it finds neither, it offers once to generate one with [`/create-verification-skill`](../../skills/create-verification-skill/SKILL.md).

Say yes and it writes `.agents/skills/verify-<app>/`, a project-local skill that teaches agents to drive your app the way a user does. It proves the skill works once before handing it over. Say no and setup moves on. You can run `/create-verification-skill` yourself any time. [Verify and ship](./06-verify-and-ship.md#create-a-project-verification-skill) covers it in depth.

If you're new to pstack, say yes. An agent that can check its own work keeps going until the check passes. An agent that can't hands every result back to you to check by hand. Of everything in this guide, the verification skill pays off the most.

Then setup offers once to generate a formal verification skill with [`/create-formal-verification-skill`](../../skills/create-formal-verification-skill/SKILL.md), unless the project already has one. Tests check the cases someone thought to write. A formal verification skill checks one key property of your code, such as "a job never runs twice at once", in every case within a stated scope. Say yes when your code has concurrency, retries, a state machine, or a parser, where a bug is costly and tests rarely reach the case that breaks. Otherwise say no, and run it later if that changes. [Verify and ship](./06-verify-and-ship.md#prove-a-property-with-a-formal-verification-skill) covers it.

After setup, start a new chat. The model rule applies to new sessions.

## Keep the cost in check

pstack spends extra tokens on subagents and review panels. That's the price of the rigor. To spend fewer:

- Rerun `/setup-pstack` and pick a smaller reasoning budget or cheaper models. A strong model in the main chat with cheaper, faster models (`gemini-3.8-flash-high`) in the exploration roles is a good split.
- Set a role to `auto` or `inherit-parent` so it runs on the chat's own model (`Model: "inherit"`).
- Shorten a panel list. Each entry runs one subagent.
- Save `/poteto-mode` for work that needs rigor. A small, obvious edit doesn't.

## Run your first task

Pick something real but small, and describe it the way you'd describe it to a colleague:

```text
/poteto-mode add a --json flag to this command. text output stays byte-identical. verify both.
```

Watch the todo list. Its first items are the matched playbook's steps copied in, the Feature playbook for this prompt. If `/poteto-mode` skips a step, the step stays in the list with `skip: <reason>`, so you can see what it chose not to do.

From here you can type normal follow-ups. Once `/poteto-mode` is loaded in the conversation, it remains in context for subsequent turns until you switch tasks with `new task` or opt out.

Next: [Route work through `/poteto-mode`](./02-poteto-mode.md).

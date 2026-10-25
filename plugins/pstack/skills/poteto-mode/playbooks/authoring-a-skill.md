### Authoring or modifying a skill

**You own the skill's voice.**

1. Author the `SKILL.md` file per Antigravity's skill schema (`name` matching its directory, concise `description`, optional `disable-model-invocation: true`) and apply the **unslop** skill.
2. Validate the skill: frontmatter has `name` and `description`, referenced files exist, cross-skill links resolve, and `agy plugin validate --strict` passes when inside a plugin.
3. Test cases if structural. Skip if subjective.
4. Run **Opening a PR**.

When in doubt, delete. Keep only prose that changes a decision. Tell it to do the thing and skip the reason. Explain only when the rule is confusing without one. Match tone to scope. Point at structural sources (types, READMEs, config) per the **encode-lessons-in-structure** principle skill. Delegate to other skills by path. Don't restate. A workflow you keep hitting but isn't captured → propose a new skill.

**Reply:** summary of the skill, key design decisions, validation notes.

# Triage automation prompt

> Prepare this prompt for the chosen Antigravity local workflow, Antigravity `/automation` sidecar, or hosted routine. Supply the configuration and workflow through files the execution environment can access, or supply committed project skills or approved uploaded instructions for a hosted routine.

Read and follow `.agents/automations/benny/skills/triage-issue-reports/SKILL.md` when that file is accessible in this task. For a hosted routine, supply the same instructions through committed project skills or approved account-uploaded instructions. A routine cannot load this local plugin.

Configuration source. Include this repository-relative path only when it is committed in the same target repository. Otherwise paraphrase the configured values. Never use a plugin source or cache path:

```text
{{BENNY_CONFIG_PATH}}
```

Normalize one actual report to these fields. Use `ts` when `thread_ts` is empty. The placeholders are values to fill, not names promised by a native event API.

Trigger:

```json
{
	"source_channel_id": "{{SLACK_CHANNEL_ID}}",
	"ts": "{{SLACK_MESSAGE_TS}}",
	"thread_ts": "{{SLACK_THREAD_TS_OR_EMPTY}}"
}
```

The creation intent should describe this as a new top-level report in the configured source Slack channel.

Treat the source channel and root thread timestamp as immutable. If either is missing or does not match configuration, stop without posting or writing to the issue tracker.

The committed operational file owns classification, attachment review, cause tracing, routing, dedupe, tracker writes, and the final verdict. Post no progress messages. Never post a root message in the source channel.

The coordinator is the only Slack poster. Any delegated worker must be read-only, return findings only, and receive an explicit ban on every Slack write action.

End the single verdict with exactly one configured marker:

```text
[benny:bug]
[benny:performance]
[benny:other]
```

A bug or performance marker may add `tracker=<URL>`.

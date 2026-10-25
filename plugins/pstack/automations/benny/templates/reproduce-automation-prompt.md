# Reproduce automation prompt

> Prepare this prompt for the chosen Antigravity local workflow, Antigravity `/automation` sidecar, or hosted routine. Supply the configuration and workflow through files the execution environment can access, or supply committed project skills or approved uploaded instructions for a hosted routine.

Read and follow `.agents/automations/benny/skills/reproduce-and-fix-issues/SKILL.md` when that file is accessible in this task. For a hosted routine, supply the same instructions through committed project skills or approved account-uploaded instructions. A routine cannot load this local plugin.

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

The creation intent should describe this as a new top-level report in the configured source Slack channel. It should include the configured repository, default branch, issue tracker, control adapter, feature map, and draft pull request capability.

Treat the source channel and root thread timestamp as immutable. If either is missing or does not match configuration, stop without posting.

Wait for a configured triage marker from the configured triage identity in this exact thread. Proceed only for `[benny:bug]` or `[benny:performance]`.

Require the configured control-adapter skill before attempting a repro. Reproduce the exact discriminating symptom twice through the real UI. Verify existing pull requests or commits without authoring over them. Attempt a bounded fix only after a confirmed repro and the operational file's fix gate.

The coordinator is the only Slack poster. Every child prompt must forbid `SendSlackMessage`, `PostToSlack`, `chat.postMessage`, and all other Slack writes. Children return findings only.

Never post a root message in the source channel.

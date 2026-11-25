# Benny for Antigravity

Benny keeps two upstream workflows. One triages Slack reports in their original threads. The other reproduces confirmed bugs, verifies existing fixes, and may prepare a bounded draft GitHub PR. Neither merges or deploys.

Read [setup](./skills/setup-benny/SKILL.md) before enabling anything. Keep user configuration outside the copied pack. Operational files are direct workflow instructions, not registered plugin skills.

For a local run, use an authorized `google-antigravity` Python SDK or headless `agy -p` backend with the needed Slack, repository, tracker, and UI access. A requested Antigravity `/automation` sidecar (`~/.gemini/config/sidecars/<slug>/sidecar.json` with `"builtin": "schedule"`, enabled in `~/.gemini/config/config.json`) can check configured reports since its last stored processing position. The app must stay open and the machine awake. Store that position outside the pack and skip completed reports.

Hosted or webhook-triggered Antigravity workflows support schedules, authenticated API triggers, and GitHub events. They cannot read a local plugin or personal skills. Supply committed project skills or approved account-uploaded instructions. Do not assume a native Slack-message trigger. Use an existing authorized integration to submit source-thread coordinates to the routine's API, or choose the local route. No new polling service is required by the conversion.

The package provides prompts and workflows. Installing it creates no live routine, scheduled task, Slack post, or service.

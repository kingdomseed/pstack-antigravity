# Set up Benny

Read and follow [setup-benny](./skills/setup-benny/SKILL.md). This is the entry point for the dormant Antigravity workflow pack.

Preserve the two workflows, the original Slack thread, duplicate detection, trusted triage markers, existing-fix verification, and draft-only GitHub PRs. Do not create scheduled tasks or post to Slack until the user explicitly requests those actions with the intended channel and scope.

Choose an authorized `google-antigravity` Python SDK or headless CLI route, Antigravity `/automation` sidecar, or hosted routine. Hosted routines need accessible committed project skills or approved uploaded instructions; they cannot read local plugins. Do not assume local files, connector permissions, or event payload fields are available in every client. Keep user configuration and secrets outside the pack.

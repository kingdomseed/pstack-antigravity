---
name: make-bot-ui
description: >-
  Use when building a custom UI (page, dashboard, buttons) that triggers an
  Antigravity workflow or sidecar automation via the google-antigravity SDK,
  headless agy -p, or a local webhook server, including exposing that UI on Tailscale.
disable-model-invocation: true
---
# Make a bot UI

Build the small UI the user requested. Buttons submit structured JSON to a trusted local backend, and credentials stay out of browser content and chat.

1. Choose an existing supported execution route. Use the [`google-antigravity` Python SDK](https://pypi.org/project/google-antigravity/) (`Antigravity.run` / `Antigravity.stream`), headless `agy -p`, or an Antigravity `/automation` sidecar behind a local server for workflow actions and streamed results.
2. Define the small set of actions and JSON inputs. Validate them on the server. Treat user-entered values as untrusted data, not instructions. The backend owns authentication and credentials. Use a secret store (`request_secret` when running in T3 Code, or a backend environment file outside the repo). Never place an API key or webhook secret in browser code or chat logs.
3. Implement only the UI and execution route requested. A plugin conversion does not build or deploy a bot service on its own. Keep local services local unless network exposure is requested.
4. When the user asks to expose the UI on Tailscale, reuse the existing Tailscale node (`tailscale status` and `tailscale ip -4`), bind the local server to `0.0.0.0:<port>`, and give the user both `http://<hostname>.<tailnet>.ts.net:<port>` and `http://<100.x.x.x>:<port>`. Never ask for Tailscale credentials in chat.
5. Exercise one harmless request through the real UI and backend. Confirm that the intended workflow starts and returns visible status or a result, and that credentials do not enter content or logs. Preserve the backend's permissions and approvals. Report unavailable tools or account access plainly.

Recurring local checks use Antigravity's `schedule` tool (in-session timers or cron) or `/automation` sidecars (`~/.gemini/automations/<name>/automation.toml`). Install or enable none of these without the user's request. A button does not grant merge or deployment authority.

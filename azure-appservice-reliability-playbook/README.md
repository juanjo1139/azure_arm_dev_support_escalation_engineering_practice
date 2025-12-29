
# Azure App Service Reliability Playbook

This mini-project demonstrates triage and mitigation for intermittent 500 errors and dependency failures using an example Flask app deployed to Azure App Service.

## Quick Start
1. Install Azure CLI and log in: `az login`
2. Run `./deploy.ps1` (PowerShell) to provision a resource group, App Service plan, Web App, and Application Insights; then deploy the app.
3. Browse to `/simulate` and toggle failures with App Settings (`APP_FAILMODE`).

## Diagnose & Solve Steps
- **Scope & impact**: timestamps, endpoints, recent changes.
- **Platform health**: Azure Service Health; App Service diagnostics; resource metrics.
- **Logs/telemetry**: Application Insights traces/exceptions; App Service HTTP logs; Kudu console.
- **Config & dependencies**: connection strings, secrets, TLS certs, outbound rules, quotas.
- **Mitigation**: rollback via deployment slots, scale out, restart, clear temp storage.
- **Root cause narrative**: tie 500s to dependency timeouts, bad secrets, or CPU spikes.

## App Settings Used
- `APP_FAILMODE`: `none | db_timeout | bad_secret | spike`
- `APP_SECRET`: if empty and `bad_secret` mode, app fails to simulate misconfiguration.

## Post-incident
- Document: action items, guardrails (alerts, tests), CI/CD gates, runbooks.

See `runbook.md` and `postmortem-template.md`.

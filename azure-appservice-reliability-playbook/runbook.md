
# Reliability Triage Runbook

## Intake
- Confirm symptoms (HTTP 500s, latency) and scope.
- Collect timestamps, regions, recent deployments.

## Triage
1. Azure App Service Diagnostics: Runtime checks, common problems.
2. Application Insights: Exceptions, dependency failures, Live Metrics.
3. Kudu: Console logs, process info, environment variables.
4. Config review: App settings, secrets, connection strings, slots.

## Mitigation
- Roll back recent deployment (swap slots).
- Scale out temporarily; restart app.
- Feature flag toggle to disable failing path.

## Root Cause & Fix
- Identify misconfig or dependency outage; add retries/backoff.
- Add alerts and run tests in CI/CD.

## Communication
- Hourly updates (facts/unknowns, mitigations, next actions).
- Executive summary (business impact, ETA, next check-in).

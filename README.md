
# Azure ARM Developer Support Escalation Engineering Practice

This pack contains five mini-projects and templates to demonstrate capabilities aligned to the Azure ARM Developer Support Escalation Engineer role.

## Contents
1. **azure-appservice-reliability-playbook/** – Flask app + runbook to triage Azure App Service outages (500s, timeouts, misconfig).
2. **powershell-diagnostic-collector/** – PowerShell script to gather diagnostics via Azure CLI.
3. **siem-tuning-mock/** – Sentinel-style tuning examples (KQL, watchlist, analytic rules).
4. **agentic-ai-troubleshooter/** – Heuristic agent that reads logs and proposes next steps.
5. **communication-templates/** – Status updates, escalation emails, postmortem template.

## Quick Start
- Deploy the app service demo: see `azure-appservice-reliability-playbook/README.md` and run `deploy.ps1`.
- Collect diagnostics: run `powershell-diagnostic-collector/collect-appservice-diagnostics.ps1`.
- Review SIEM tuning and KQL: open `siem-tuning-mock/`.
- Run the agent: `python agent.py ../siem-tuning-mock/dataset/simulated_logs.jsonl`.
- Use comms templates during simulations.

## Notes
- Scripts assume Azure CLI is installed and you have appropriate permissions.
- Replace placeholder names as needed.

## SC-100/SC-200 Angle
- Demonstrates architecture-aware triage (SC-100) and operational analytics/tuning (SC-200).
- KQL snippets, watchlists, and rule tuning reflect Sentinel practices.

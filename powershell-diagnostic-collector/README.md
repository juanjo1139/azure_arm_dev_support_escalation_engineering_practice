
# PowerShell Diagnostic Collector

Collects Azure Web App diagnostics using Azure CLI.

## Usage
```powershell
./collect-appservice-diagnostics.ps1 -ResourceGroup rg-reliability-demo -WebAppName <your-app-name>
```
Outputs: webapp.json, appsettings.json, metrics.json, http_logs.zip.

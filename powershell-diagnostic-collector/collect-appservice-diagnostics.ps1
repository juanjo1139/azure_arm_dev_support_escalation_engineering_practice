
# Collects key diagnostics from an Azure Web App
# Usage: .\collect-appservice-diagnostics.ps1 -ResourceGroup rg -WebAppName app-name
param(
    [Parameter(Mandatory=$true)][string]$ResourceGroup,
    [Parameter(Mandatory=$true)][string]$WebAppName,
    [string]$OutDir = './out'
)

az account show 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { az login }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host 'Fetching web app details...'
az webapp show -g $ResourceGroup -n $WebAppName > "$OutDir/webapp.json"

Write-Host 'Fetching app settings...'
az webapp config appsettings list -g $ResourceGroup -n $WebAppName > "$OutDir/appsettings.json"

Write-Host 'Downloading HTTP logs (if enabled)...'
az webapp log download -g $ResourceGroup -n $WebAppName --log-file "$OutDir/http_logs.zip"

Write-Host 'Listing recent metrics...'
az monitor metrics list --resource $(az webapp show -g $ResourceGroup -n $WebAppName --query id -o tsv) 
  --metric Requests, Http5xx, CpuPercentage, MemoryWorkingSet 
  --interval PT1H --offset 24h > "$OutDir/metrics.json"

Write-Host 'Collecting App Insights exceptions (if linked)...'
$ikey = (az webapp config appsettings list -g $ResourceGroup -n $WebAppName --query "[?name=='APPINSIGHTS_INSTRUMENTATIONKEY'].value | [0]" -o tsv)
if ($ikey) {
  Write-Host 'Please query exceptions via Azure Portal or API - placeholder collected.'
}

Write-Host "Done. Output in $OutDir"

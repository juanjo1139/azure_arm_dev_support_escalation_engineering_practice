
# Requires: Azure CLI and permissions
param(
    [string]$Location = 'eastus',
    [string]$RgName = 'rg-reliability-demo',
    [string]$PlanName = 'asp-reliability-demo',
    [string]$WebAppName = 'reliability-demo-$(Get-Random)',
    [string]$InsightsName = 'ai-reliability-demo'
)

Write-Host "Login to Azure if needed"
az account show 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { az login }

az group create -n $RgName -l $Location
az appservice plan create -g $RgName -n $PlanName --sku B1 --is-linux
az webapp create -g $RgName -p $PlanName -n $WebAppName --runtime 'PYTHON:3.10'

# App Insights (classic component)
az monitor app-insights component create -g $RgName -a $InsightsName -l $Location
$ikey = (az monitor app-insights component show -g $RgName -a $InsightsName --query 'instrumentationKey' -o tsv)

# Enable logging & settings
az webapp log config -g $RgName -n $WebAppName --web-server-logging filesystem
az webapp config appsettings set -g $RgName -n $WebAppName --settings 
  APP_FAILMODE=none `
  APP_SECRET=changeme `
  APPINSIGHTS_INSTRUMENTATIONKEY=$ikey

# Deploy via ZIP
$zipPath = Join-Path (Split-Path $PSScriptRoot) 'app.zip'
if (-not (Test-Path $zipPath)) {
    Write-Host 'Creating app.zip from app directory'
    Compress-Archive -Path (Join-Path $PSScriptRoot 'app/*') -DestinationPath $zipPath -Force
}
az webapp deployment source config-zip -g $RgName -n $WebAppName --src $zipPath

Write-Host "Deployment complete. Web app:"
az webapp show -g $RgName -n $WebAppName --query 'defaultHostName' -o tsv

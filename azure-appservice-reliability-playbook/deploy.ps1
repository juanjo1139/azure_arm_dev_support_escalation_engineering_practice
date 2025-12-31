
# Requires: Azure CLI and permissions
param(
    [string]$Location = 'eastus',
    [string]$RgName = 'rg-reliability-demo',
  [string]$PlanName = 'asp-reliability-demo',
  [string]$WebAppName = '',
    [string]$InsightsName = 'ai-reliability-demo'
)

Write-Host "Login to Azure if needed"
az account show 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { az login }

# Ensure required resource providers are registered for the subscription
Write-Host 'Registering required resource providers (may take a minute)'
az provider register --namespace Microsoft.Web 2>$null | Out-Null
az provider register --namespace Microsoft.Insights 2>$null | Out-Null
az provider register --namespace Microsoft.OperationalInsights 2>$null | Out-Null

# Wait until providers are registered (simple polling)
$providers = @('Microsoft.Web','Microsoft.Insights','Microsoft.OperationalInsights')
foreach ($p in $providers) {
  $state = (az provider show --namespace $p --query registrationState -o tsv) 2>$null
  $attempt = 0
  while ($state -ne 'Registered' -and $attempt -lt 40) {
    Start-Sleep -Seconds 5
    $state = (az provider show --namespace $p --query registrationState -o tsv) 2>$null
    $attempt++
  }
  if ($state -ne 'Registered') { Write-Warning "Provider $p not registered after waiting; you may need subscription permissions or to register manually." }
}

# Register Application Insights preview feature if available (may be required for some tenants)
Write-Host 'Ensuring AIWorkspacePreview feature is registered for Microsoft.Insights (may take a minute)'
try {
  az feature register --namespace microsoft.insights --name AIWorkspacePreview 2>$null | Out-Null
  $featState = (az feature show --namespace microsoft.insights --name AIWorkspacePreview --query properties.state -o tsv) 2>$null
  $fattempt = 0
  while ($featState -ne 'Registered' -and $fattempt -lt 40) {
    Start-Sleep -Seconds 5
    $featState = (az feature show --namespace microsoft.insights --name AIWorkspacePreview --query properties.state -o tsv) 2>$null
    $fattempt++
  }
  if ($featState -ne 'Registered') { Write-Warning 'AIWorkspacePreview feature not registered; some App Insights functionality may not be available.' }
} catch {
  Write-Warning 'Could not register AIWorkspacePreview feature (insufficient permissions?)'
}

az group create -n $RgName -l $Location
az appservice plan create -g $RgName -n $PlanName --sku B1 --is-linux

# Generate a unique web app name if not provided
if ([string]::IsNullOrWhiteSpace($WebAppName)) {
  $rand = Get-Random -Maximum 10000
  $WebAppName = "reliability-demo-$rand"
  Write-Host "Using generated Web App name: $WebAppName"
}

az webapp create -g $RgName -p $PlanName -n $WebAppName --runtime 'PYTHON:3.10'

# App Insights (classic component)
az monitor app-insights component create -g $RgName -a $InsightsName -l $Location
$ikey = (az monitor app-insights component show -g $RgName -a $InsightsName --query 'instrumentationKey' -o tsv)

# Enable logging & settings
az webapp log config -g $RgName -n $WebAppName --web-server-logging filesystem
# Configure app settings; only set APPINSIGHTS_INSTRUMENTATIONKEY if we retrieved an instrumentation key
$settings = @('APP_FAILMODE=none','APP_SECRET=changeme')
if (-not [string]::IsNullOrWhiteSpace($ikey)) { $settings += "APPINSIGHTS_INSTRUMENTATIONKEY=$ikey" } else { Write-Warning 'Instrumentation key not found; skipping APPINSIGHTS_INSTRUMENTATIONKEY app setting.' }
az webapp config appsettings set -g $RgName -n $WebAppName --settings $settings

# Deploy via ZIP
$zipPath = Join-Path (Split-Path $PSScriptRoot) 'app.zip'
if (-not (Test-Path $zipPath)) {
    Write-Host 'Creating app.zip from app directory'
    Compress-Archive -Path (Join-Path $PSScriptRoot 'app/*') -DestinationPath $zipPath -Force
}
az webapp deployment source config-zip -g $RgName -n $WebAppName --src $zipPath

Write-Host "Deployment complete. Web app:"
az webapp show -g $RgName -n $WebAppName --query 'defaultHostName' -o tsv

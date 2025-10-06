#Requires -Modules Az.Accounts, Az.Resources, Az.Compute, Az.Network

# --- Config ---
$SubscriptionId = 'da883fd8-76c8-4ca5-a7e6-8567ae83ce10'
$ResourceGroup  = 'rg-hpcuk-cluster'
$TemplateFile   = '.\hpc-cluster-template.json'
$ParamsFile     = '.\hpc-cluster-params.json'
$DeploymentName = 'hpc-2019-' + (Get-Date -Format 'yyyyMMdd-HHmmss')

# --- Login & context ---
# Install-Module Az -Scope CurrentUser -Force   # (run once if needed)
# Connect-AzAccount -ErrorAction Stop | Out-Null
# Set-AzContext -Subscription $SubscriptionId -ErrorAction Stop

Write-Host "Validating template..." -ForegroundColor Cyan

# --- VALIDATE ---
$validation = Test-AzResourceGroupDeployment `
  -ResourceGroupName $ResourceGroup `
  -TemplateFile $TemplateFile `
  -TemplateParameterFile $ParamsFile `
  -ErrorAction SilentlyContinue -ErrorVariable vErr

if ($vErr) {
  Write-Host "Validation failed:" -ForegroundColor Red
  $vErr | ForEach-Object {
    if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } else { $_ }
  }
  exit 1
}

Write-Host "Validation OK. Starting deployment..." -ForegroundColor Green

# --- DEPLOY ---
$deploy = New-AzResourceGroupDeployment `
  -Name $DeploymentName `
  -ResourceGroupName $ResourceGroup `
  -TemplateFile $TemplateFile `
  -TemplateParameterFile $ParamsFile `
  -Mode Incremental `
  -Verbose -ErrorAction Stop

Write-Host "Deployment complete." -ForegroundColor Green

# Show outputs (if any)
if ($deploy.Outputs) {
  $deploy.Outputs | ConvertTo-Json -Depth 10
} else {
  Write-Host "(No outputs defined in template.)"
}

# --- Post-deploy quick checks (optional) ---
# Head node extension status (adjust VM name if different)
try {
  $ext = Get-AzVMExtension -ResourceGroupName $ResourceGroup -VMName 'hpcuk1' -Name 'AADLoginForWindows' -ErrorAction Stop
  "{0} : {1}" -f $ext.Name, $ext.ProvisioningState | Write-Host
} catch { }
try {
  $nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroup |
         Where-Object { $_.VirtualMachine -and $_.VirtualMachine.Id -match '/virtualMachines/hpcuk1$' } |
         Select-Object -First 1
  if ($nic) { "Head node private IP: {0}" -f $nic.IpConfigurations[0].PrivateIpAddress | Write-Host }
} catch { }

# create-share.ps1
$ErrorActionPreference = 'Stop'

$sharePath = 'C:\HPCShared'
$shareName = 'HPCShared'

if (!(Test-Path $sharePath)) { New-Item -ItemType Directory -Path $sharePath -Force | Out-Null }

# NTFS Modify for Everyone
cmd /c "icacls `"$sharePath`" /grant `"Everyone`":(OI)(CI)M" | Out-Null

# SMB share with Change for Everyone
$existing = Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue
if ($null -eq $existing) {
  New-SmbShare -Name $shareName -Path $sharePath -ChangeAccess 'Everyone' -CachingMode Manual | Out-Null
} else {
  Grant-SmbShareAccess -Name $shareName -AccountName 'Everyone' -AccessRight Change -Force -ErrorAction SilentlyContinue | Out-Null
}

# Harden + firewall
try { if ((Get-SmbServerConfiguration).EnableSMB1Protocol) { Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force | Out-Null } } catch {}
Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" -ErrorAction SilentlyContinue |
  Where-Object { $_.Enabled -ne 'True' } | Set-NetFirewallRule -Enabled True | Out-Null

Write-Host "Share ready: \\$env:COMPUTERNAME\$shareName"

# disable-ieesc.ps1
$ErrorActionPreference = 'Stop'

$paths = @(
  'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components',
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Active Setup\Installed Components'
)

$targets = @('IEHardenAdmin','IEHardenUser')

foreach ($root in $paths) {
  if (Test-Path $root) {
    Get-ChildItem $root | ForEach-Object {
      $p = Get-ItemProperty $_.PsPath -ErrorAction SilentlyContinue
      if ($null -ne $p -and $targets -contains $p.ComponentID) {
        Write-Host "Disabling IE ESC: $($p.ComponentID) at $($_.PsPath)"
        Set-ItemProperty -Path $_.PsPath -Name 'IsInstalled' -Value 0 -Force
      }
    }
  }
}

# Stop/restart Explorer if present (RDS/AVD sessions)
Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "IE Enhanced Security Configuration disabled for Admins and Users."

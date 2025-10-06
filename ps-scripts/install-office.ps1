# install-office.ps1 — download ZIP, extract to C:\O365Build, then run exactly:
#   .\setup.exe /configure configuration.xml
$ErrorActionPreference = 'Stop'

$zipUrl    = 'https://hpccluster251003.blob.core.windows.net/install/o365build.zip'
$zipPath   = 'C:\Temp\o365build.zip'
$localRoot = 'C:\O365Build'

# Prep
New-Item -ItemType Directory -Path (Split-Path $zipPath) -Force | Out-Null
if (Test-Path $localRoot) { Remove-Item "$localRoot\*" -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $localRoot -Force | Out-Null

# Download (BITS → curl fallback)
try {
  Start-BitsTransfer -Source $zipUrl -Destination $zipPath -ErrorAction Stop
} catch {
  & "$env:SystemRoot\System32\curl.exe" -L --retry 5 --retry-delay 2 -o "$zipPath" "$zipUrl"
}
if (-not (Test-Path $zipPath)) { throw "Download failed: $zipPath not found." }

# Extract
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $localRoot)

# Flatten one level if needed (harmless if not)
$top = Get-ChildItem $localRoot -Force
if ($top.Count -eq 1 -and $top[0].PSIsContainer) {
  Get-ChildItem $top[0].FullName -Force | ForEach-Object {
    $dest = Join-Path $localRoot $_.Name
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    Move-Item $_.FullName $localRoot
  }
  Remove-Item $top[0].FullName -Recurse -Force
}

# Verify files exist
if (-not (Test-Path (Join-Path $localRoot 'setup.exe')))       { throw "setup.exe missing in $localRoot" }
if (-not (Test-Path (Join-Path $localRoot 'configuration.xml'))) { throw "configuration.xml missing in $localRoot" }

# *** Install exactly like manual run ***
Push-Location $localRoot
try {
  & .\setup.exe /configure configuration.xml
} finally {
  Pop-Location
}

# wrapper.ps1
# Log file to track progress in a persistent directory
$logFile = "C:\Logs\install-office-share-log.txt"

# Ensure the logging directory exists before writing to it
try {
    New-Item -ItemType Directory -Path (Split-Path $logFile) -Force | Out-Null
}
catch {
    Write-Host "Error: Failed to create log directory C:\Logs. Logging may not be available."
    # Exit or continue based on your needs. For this example, we'll continue.
}

# Function to log messages
function Write-Log {
    param([string]$message)
    Add-Content -Path $logFile -Value "[$(Get-Date)] $message"
}

Write-Log "Starting installation scripts..."

# Set ErrorActionPreference to stop on errors
$ErrorActionPreference = "Stop"

# Execute disable-ieesc.ps1
try {
    Write-Log "Executing disable-ieesc.ps1..."
    & "scripts\\disable-ieesc.ps1"
    Write-Log "Successfully executed disable-ieesc.ps1."
}
catch {
    Write-Log "Error: An exception occurred during disable-ieesc.ps1 execution. Error details: $($_.Exception.Message)"
    exit 1
}

# Execute install-office.ps1
try {
    Write-Log "Executing install-office.ps1..."
    & "scripts\\install-office.ps1"
    Write-Log "Successfully executed install-office.ps1."
}
catch {
    Write-Log "Error: An exception occurred during install-office.ps1 execution. Error details: $($_.Exception.Message)"
    exit 1
}

# Execute create-share.ps1
try {
    Write-Log "Executing create-share.ps1..."
    & "scripts\\create-share.ps1"
    Write-Log "Successfully executed create-share.ps1."
}
catch {
    Write-Log "Error: An exception occurred during create-share.ps1 execution. Error details: $($_.Exception.Message)"
    exit 1
}

Write-Log "All scripts completed successfully."
exit 0

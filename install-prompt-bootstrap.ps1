# Requires -Version 5.1
$ErrorActionPreference = 'Stop'

if (-not $PSVersionTable) {
    Write-Error 'This installer must be run from PowerShell.'
    exit 1
}

$repoUrl = 'https://raw.githubusercontent.com/mdkeenan/cli-prompt-bootstrap/main/profile.ps1'
$backup = "$PROFILE.original"

if ((Test-Path -LiteralPath $PROFILE) -and -not (Test-Path -LiteralPath $backup)) {
    Copy-Item -LiteralPath $PROFILE -Destination $backup
}

$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path -LiteralPath $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

Invoke-RestMethod -Uri $repoUrl -OutFile $PROFILE

Write-Host "New profile installed at $PROFILE. Run '. `$PROFILE' or restart your shell to apply."

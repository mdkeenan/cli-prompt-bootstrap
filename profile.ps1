# PowerShell profile: custom prompt and shell defaults.

# History settings (PowerShell caps MaximumHistoryCount at 32767)
$MaximumHistoryCount = 32767
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    Set-PSReadLineOption -HistoryNoDuplicates -ErrorAction SilentlyContinue
}

function global:Get-PromptDirectory {
    param([string]$Path)

    if (-not $HOME) {
        $leaf = Split-Path -Leaf $Path
        return if ($leaf) { $leaf } else { $Path }
    }

    try {
        $currentPath = [System.IO.Path]::GetFullPath($Path)
        $homePath = [System.IO.Path]::GetFullPath($HOME)
    } catch {
        $leaf = Split-Path -Leaf $Path
        return if ($leaf) { $leaf } else { $Path }
    }

    if ($currentPath.Equals($homePath, [StringComparison]::OrdinalIgnoreCase)) {
        return '~'
    }

    $homePrefix = $homePath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if ($currentPath.StartsWith($homePrefix, [StringComparison]::OrdinalIgnoreCase)) {
        $relative = $currentPath.Substring($homePrefix.Length).Replace('\', '/')
        return "~/$relative"
    }

    $leaf = Split-Path -Leaf $currentPath
    if (-not $leaf) { return $currentPath }
    return $leaf
}

function global:prompt {
    $time = Get-Date -Format 'HH:mm:ss'
    $user = if ($env:USERNAME) { $env:USERNAME } else { $env:USER }
    $hostname = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { (hostname) }
    $location = Get-Location
    $leaf = Get-PromptDirectory $location.Path

    $isPrivileged = $false
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        if ($IsWindows) {
            $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = [Security.Principal.WindowsPrincipal]$identity
            $adminSid = [Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')
            $isPrivileged = $principal.IsInRole($adminSid)
        } elseif ($IsLinux -or $IsMacOS) {
            $isRoot = (id -u) -eq 0
            $isPrivileged = $isRoot
            if (-not $isPrivileged) {
                $groups = (id -nG) -split '\s+'
                $isPrivileged = 'sudo' -in $groups -or 'wheel' -in $groups -or 'admin' -in $groups
            }
        }
    } else {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]$identity
        $adminSid = [Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')
        $isPrivileged = $principal.IsInRole($adminSid)
    }

    $Host.UI.RawUI.WindowTitle = "${user}@${hostname}: $($location.Path)"

    $privLabel = if ($isPrivileged) { 'admuser' } else { 'stduser' }
    $privColor = if ($isPrivileged) { 'Red' } else { 'DarkGray' }

    Write-Host '[' -NoNewline -ForegroundColor Yellow
    Write-Host $time -NoNewline
    Write-Host ':' -NoNewline -ForegroundColor Yellow
    Write-Host $user -NoNewline -ForegroundColor Green
    Write-Host ':' -NoNewline -ForegroundColor Yellow
    Write-Host $privLabel -NoNewline -ForegroundColor $privColor
    Write-Host ':' -NoNewline -ForegroundColor Yellow
    Write-Host $hostname -NoNewline -ForegroundColor Cyan
    Write-Host ':' -NoNewline -ForegroundColor Yellow
    Write-Host $leaf -NoNewline -ForegroundColor Blue
    Write-Host ']$' -NoNewline -ForegroundColor Yellow
    return ' '
}

function global:ll { Get-ChildItem -Force }
function global:la { Get-ChildItem -Force | Where-Object { $_.Name -notin '.', '..' } }
function global:l  { Get-ChildItem -Name }

$aliasesPath = Join-Path $HOME '.powershell_aliases.ps1'
if (Test-Path $aliasesPath) {
    . $aliasesPath
}

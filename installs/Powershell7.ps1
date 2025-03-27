<#
.SYNOPSIS
PS7 installation script
.DESCRIPTION
Installs PS7 via winget and installs the dotfiles
.AUTHOR
Dubsky
.REPOSITORY
https://github.com/dubskysteam/WinFlux
.VERSION
1.0.0
#>

Import-Module "$PSScriptRoot/../modules/DotfilesInstaller.psm1" -Force


if ($PSVersionTable.PSVersion.Major -ge 7) {
    Write-Host "✅ PowerShell 7+ detected (v$($PSVersionTable.PSVersion))" -ForegroundColor Green
} else {
    Write-Host "❌ No PowerShell 7+ detected, now installing" -ForegroundColor Red
    winget install -e --id Microsoft.PowerShell --source winget --accept-source-agreements
}

Install-Dotfiles -GitHubUser "DubskySteam" `
                 -RepoName ".dotfiles" `
                 -SourcePath "powershell/Microsoft.Powershell_profile.ps1" `
                 -LocalPath "$HOME\Documents\PowerShell" `
                 -CleanBeforeInstall

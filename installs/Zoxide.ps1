<#
.SYNOPSIS
    Zoxide installation script
.DESCRIPTION
    Installs Zoxide via winget and installs the dotfiles
.AUTHOR
    Dubsky
.REPOSITORY
    https://github.com/dubskysteam/WinFlux
.VERSION
    1.0.0
#>

Import-Module "$PSScriptRoot/../modules/DotfilesInstaller.psm1" -Force

if (-not (Get-Command z -ErrorAction SilentlyContinue)) {
    winget install -e --id ajeetdsouza.zoxide --silent --accept-source-agreements
}

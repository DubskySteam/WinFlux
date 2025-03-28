<#
.SYNOPSIS
    FNM installation script
.DESCRIPTION
    Installs FNM via winget and installs the dotfiles
.AUTHOR
    Dubsky
.REPOSITORY
    https://github.com/dubskysteam/WinFlux
.VERSION
    1.0.0
#>

Import-Module "$PSScriptRoot/../modules/DotfilesInstaller.psm1" -Force

if (-not (Get-Command fnm -ErrorAction SilentlyContinue)) {
    winget install -e --id Schniz.fnm --silent --accept-source-agreements
}

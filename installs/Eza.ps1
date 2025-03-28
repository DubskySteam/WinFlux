<#
.SYNOPSIS
    Eza installation script
.DESCRIPTION
    Installs Eza via winget and installs the dotfiles
.AUTHOR
    Dubsky
.REPOSITORY
    https://github.com/dubskysteam/WinFlux
.VERSION
    1.0.0
#>

Import-Module "$PSScriptRoot/../modules/DotfilesInstaller.psm1" -Force

if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
    winget install -e --id eza-community.eza --silent --accept-source-agreements
}

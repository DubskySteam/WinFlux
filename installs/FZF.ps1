<#
.SYNOPSIS
    FZF installation script
.DESCRIPTION
    Installs FZF via winget and installs the dotfiles
.AUTHOR
    Dubsky
.REPOSITORY
    https://github.com/dubskysteam/WinFlux
.VERSION
    1.0.0
#>

Import-Module "$PSScriptRoot/../modules/DotfilesInstaller.psm1" -Force

if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
    winget install -e --id junegun.fzf --silent --accept-source-agreements
}

<#
.SYNOPSIS
    RipGrep installation script
.DESCRIPTION
    Installs RipGrep via winget and installs the dotfiles
.AUTHOR
    Dubsky
.REPOSITORY
    https://github.com/dubskysteam/WinFlux
.VERSION
    1.0.0
#>

Import-Module "$PSScriptRoot/../modules/DotfilesInstaller.psm1" -Force

if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
    winget install -e --id BurntSushi.ripgrep.MSVC --silent --accept-source-agreements
}

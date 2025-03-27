<#
.SYNOPSIS
Wezterm installation script
.DESCRIPTION
Installs Wezterm via winget and installs the dotfiles
.AUTHOR
Dubsky
.REPOSITORY
https://github.com/dubskysteam/WinFlux
.VERSION
1.0.0
#>

Import-Module "$PSScriptRoot/../modules/DotfilesInstaller.psm1" -Force

if (-not (Get-Command wezterm -ErrorAction SilentlyContinue)) {
    winget install -e --id wez.wezterm --accept-source-agreements
}

Install-Dotfiles -GitHubUser "DubskySteam" `
                 -RepoName ".dotfiles" `
                 -SourcePath "wezterm/.config/wezterm" `
                 -LocalPath "$HOME" `
                 -CleanBeforeInstall

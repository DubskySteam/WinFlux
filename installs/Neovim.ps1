<#
.SYNOPSIS
Neovim installation script
.DESCRIPTION
Installs Neovim via winget and installs the dotfiles
.AUTHOR
Dubsky
.REPOSITORY
https://github.com/dubskysteam/WinFlux
.VERSION
1.0.0
#>

Import-Module "$PSScriptRoot/../modules/DotfilesInstaller.psm1" -Force

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    winget install Neovim.Neovim --accept-source-agreements
}

Install-Dotfiles -GitHubUser "DubskySteam" `
                 -RepoName ".dotfiles" `
                 -SourcePath "nvim/.config/nvim" `
                 -LocalPath "$env:LOCALAPPDATA\nvim" `
                 -CleanBeforeInstall

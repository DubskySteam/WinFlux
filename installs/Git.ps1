<#
.SYNOPSIS
    Git installation script
.DESCRIPTION
    Installs Git via winget and installs the dotfiles
.AUTHOR
    Dubsky
.REPOSITORY
    https://github.com/dubskysteam/WinFlux
.VERSION
    1.0.0
#>

Import-Module "$PSScriptRoot/../modules/DotfilesInstaller.psm1" -Force

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
        winget install -e --id Git.Git --silent
}

Install-Dotfiles -GitHubUser "DubskySteam" `
                 -RepoName ".dotfiles" `
                 -SourcePath "git/.gitconfig" `
                 -LocalPath "$HOME" `
                 -CleanBeforeInstall

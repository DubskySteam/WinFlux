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

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install -e --id Git.Git --silent --accept-source-agreements
}

Install-Dotfiles -GitHubUser "DubskySteam" `
                 -RepoName ".dotfiles" `
                 -SourcePath "win/git/.gitconfig" `
                 -LocalPath "$HOME" `
                 -CleanBeforeInstall

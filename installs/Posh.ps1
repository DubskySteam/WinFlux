<#
.SYNOPSIS
    OMP installation script
.DESCRIPTION
    Installs OMP via winget and installs the dotfiles
.AUTHOR
    Dubsky
.REPOSITORY
    https://github.com/dubskysteam/WinFlux
.VERSION
    1.0.0
#>

Import-Module "$PSScriptRoot/../modules/DotfilesInstaller.psm1" -Force

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    winget install -e --id JanDeDobbeleer.OhMyPosh --source winget --silent --accept-source-agreements
}

Write-Host "> Creating OMP environment variable" -ForegroundColor Yellow
[System.Environment]::SetEnvironmentVariable("POSH_THEMES_PATH", "$env:UserProfile\AppData\Local\Programs\oh-my-posh\themes", [System.EnvironmentVariableTarget]::User)
Write-Output "POSH_THEMES_PATH: $env:POSH_THEMES_PATH"

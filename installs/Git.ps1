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

try {
    if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
        winget install -e --id Git.Git --silent
        Write-Output "Git installed successfully"
    } else {
        Write-Output "Git already installed"
    }
    <#Wait 2seconds#>
    Start-Sleep -Seconds 2
}
catch {
    throw "Git installation failed: $_"
}

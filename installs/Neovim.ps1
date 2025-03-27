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

try {
    if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
        winget install Neovim.Neovim --silent
        Write-Output "Neovim installed successfully"
    } else {
        Write-Output "Neovim already installed"
    }
    <#Wait 2seconds#>
    Start-Sleep -Seconds 2
}
catch {
    throw "Neovim installation failed: $_"
}
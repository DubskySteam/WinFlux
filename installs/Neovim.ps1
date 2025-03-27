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
        winget install -e --id Neovim.Neovim --silent
        Write-Output "Neovim installed successfully"
        Write-Output "Trying to install dotfiles"
        $repoUrl = "https://api.github.com/repos/DubskySteam/.dotfiles/tree/main/nvim/.config/nvim"
        $localPath = "$env:LOCALAPPDATA\nvim"

        $files = (Invoke-RestMethod -Uri $repoUrl) | Where-Object { $_.type -eq "file" }

        foreach ($file in $files) {
            $dest = Join-Path $localPath $file.path.Replace("nvim/", "")
            $null = New-Item -Path (Split-Path $dest -Parent) -ItemType Directory -Force
            Invoke-WebRequest -Uri $file.download_url -OutFile $dest
        }
        Write-Output "dotfiles installed"
    } else {
        Write-Output "Neovim already installed"
    }
    <#Wait 2seconds#>
    Start-Sleep -Seconds 2
}
catch {
    throw "Neovim installation failed: $_"
}

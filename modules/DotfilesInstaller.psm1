<#
.SYNOPSIS
Reusable module for installing dotfiles from GitHub
#>

function Install-Dotfiles {
    param (
        [Parameter(Mandatory=$true)]
        [string]$GitHubUser,
        
        [Parameter(Mandatory=$true)]
        [string]$RepoName,
        
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,        

        [Parameter(Mandatory=$true)]
        [string]$LocalPath,        

        [switch]$CleanBeforeInstall
    )

    function Get-GitHubFolder {
        param (
            [string]$ApiUrl,
            [string]$TargetPath
        )

        $items = Invoke-RestMethod -Uri $ApiUrl
        foreach ($item in $items) {
            $itemPath = Join-Path $TargetPath $item.name

            if ($item.type -eq "file") {
                Write-Host "  📄 $($item.path)" -NoNewline
                try {
                    Invoke-WebRequest -Uri $item.download_url -OutFile $itemPath -ErrorAction Stop
                    Write-Host " [✔]" -ForegroundColor Green
                }
                catch {
                    Write-Host " [❌]" -ForegroundColor Red
                    Write-Warning "Download failed: $_"
                }
            }
            elseif ($item.type -eq "dir") {
                Write-Host "  📂 $($item.path)" -ForegroundColor Cyan
                New-Item -Path $itemPath -ItemType Directory -Force | Out-Null
                Get-GitHubFolder -ApiUrl $item.url -TargetPath $itemPath
            }
        }
    }

    try {
        if ($CleanBeforeInstall) {
            Remove-Item -Path $LocalPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        New-Item -Path $LocalPath -ItemType Directory -Force | Out-Null

        Write-Host "🌐 Installing dotfiles from $GitHubUser/$RepoName/$SourcePath..." -ForegroundColor Magenta
        $apiUrl = "https://api.github.com/repos/$GitHubUser/$RepoName/contents/$SourcePath"
        Get-GitHubFolder -ApiUrl $apiUrl -TargetPath $LocalPath

        Write-Host "✅ Successfully installed to: $LocalPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Failed to install dotfiles: $_" -ForegroundColor Red
        return $false
    }
}

Export-ModuleMember -Function Install-Dotfiles

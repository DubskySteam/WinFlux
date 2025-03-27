<#
.SYNOPSIS
    Entry point for the installer
.DESCRIPTION
    Downloads all dependencies and runs the GUI
.AUTHOR
    Dubsky
.REPOSITORY
    https://github.com/dubskysteam/WinFlux
#>

param([switch]$NoCleanup)

try {
    $REPO_OWNER = "DubskySteam"
    $REPO_NAME = "WinFlux"
    $REPO_BRANCH = "main"
    $BASE_REPO_URL = "https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$REPO_BRANCH"

    $basePath = "$env:TEMP\WinFlux-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $null = New-Item -Path $basePath -ItemType Directory -Force -ErrorAction Stop
    Write-Host "🔧 Web install directory: $basePath" -ForegroundColor Cyan

    $fileManifest = @(
        "gui.ps1",
        "modules/DotfilesInstaller.psm1",
        "installs/Neovim.ps1",
        "installs/Git.ps1",
        "installs/WezTerm.ps1"
    ) | ForEach-Object {
        [PSCustomObject]@{
            Name = $_
            Url  = "$BASE_REPO_URL/$_"
        }
    }

    function Get-WebFiles {
        param($Files, $BasePath)
        
        $Files | ForEach-Object -Parallel {
            $dest = Join-Path $using:basePath $_.Name
            $parentDir = [System.IO.Path]::GetDirectoryName($dest)
            
            if (-not (Test-Path $parentDir)) {
                $null = New-Item -Path $parentDir -ItemType Directory -Force
            }

            try {
                Write-Host "⬇️ Downloading $($_.Name)..."
                $ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest -Uri $_.Url -OutFile $dest -ErrorAction Stop
            }
            catch {
                throw "Failed to download $($_.Name): $_"
            }
        } -ThrottleLimit 4
    }

    Get-WebFiles -Files $fileManifest -BasePath $basePath

    #$guiPath = Join-Path $PSScriptRoot "gui.ps1"
    $guiPath = Join-Path $basePath "gui.ps1"
    if (-not (Test-Path $guiPath -PathType Leaf)) {
        throw "Critical error: GUI script missing at $guiPath"
    }

    . $guiPath
    if (-not (Get-Command Show-SetupGUI -ErrorAction SilentlyContinue)) {
        throw "GUI function 'Show-SetupGUI' not found"
    }

    Write-Host "🚀 Launching WinFlux..." -ForegroundColor Magenta
    Show-SetupGUI -RootPath $basePath
}
catch {
    Write-Error "❌ SETUP FAILED: $_"
    exit 1
}
finally {
    if (-not $NoCleanup -and $basePath -and (Test-Path $basePath)) {
        try {
            Write-Host "🧹 Cleaning up temporary files..." -NoNewline
            Remove-Item -Path $basePath -Recurse -Force -ErrorAction Stop
            Write-Host " [✔]" -ForegroundColor Green
        }
        catch {
            Write-Host " [❌]" -ForegroundColor Red
            Write-Warning "Failed to clean up temporary files: $_"
        }
    }
    elseif ($NoCleanup) {
        Write-Host "🔍 Cache preservation enabled (--NoCleanup specified)" -ForegroundColor Yellow
    }
}

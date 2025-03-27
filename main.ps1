<#
.SYNOPSIS
    Entry point for the installer
.DESCRIPTION
    Downloads all dependencies and runs the GUI
.AUTHOR
    Dubsky
.REPOSITORY
    https://github.com/dubskysteam/WinFlux
.VERSION
    1.1.0
#>

param([switch]$NoCleanup)

try {
    $basePath = "$env:TEMP\WinFlux-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $null = New-Item -Path $basePath -ItemType Directory -Force -ErrorAction Stop
    Write-Host "🔧 Web install directory: $basePath" -ForegroundColor Cyan

    $fileManifest = @(
        @{
            Name = "gui.ps1"
            Url  = "https://raw.githubusercontent.com/DubskySteam/WinFlux/main/gui.ps1"
        },
        @{
            Name = "installs/Neovim.ps1"
            Url  = "https://raw.githubusercontent.com/DubskySteam/WinFlux/main/installs/Neovim.ps1"
        }
    )

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
                Write-Host " [❌]" -ForegroundColor Red
                throw "Failed to download $($_.Name): $_"
            }
        } -ThrottleLimit 4
    }

    Get-WebFiles -Files $fileManifest -BasePath $basePath

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

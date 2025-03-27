<#
.SYNOPSIS
    Draws the GUI
.DESCRIPTION
    Setup form with tabs for applications and tweaks
.AUTHOR
    Dubsky
.REPOSITORY
    https://github.com/dubskysteam/WinFlux
.VERSION
    1.1.0
#>

function Show-SetupGUI {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$RootPath
    )
    
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "WinFlux Setup"
    $form.Size = New-Object System.Drawing.Size(700, 650)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedSingle"
    $form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

    $mainPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $mainPanel.Dock = "Fill"
    $mainPanel.Padding = New-Object System.Windows.Forms.Padding(10)
    $mainPanel.RowCount = 3
    $mainPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))
    $mainPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
    $mainPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
    $form.Controls.Add($mainPanel)

    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Dock = "Fill"
    $tabControl.Appearance = "FlatButtons"
    $tabControl.SizeMode = "Fixed"
    $tabControl.ItemSize = New-Object System.Drawing.Size(120, 30)
    $mainPanel.Controls.Add($tabControl, 0, 0)

    $appsTab = New-TabPage -Name "📦 Applications" -Items (Get-InstallableItems -Path "$RootPath/installs")
    $tweaksTab = New-TabPage -Name "⚙️ Tweaks" -Items (Get-InstallableItems -Path "$RootPath/tweaks")
    $tabControl.Controls.AddRange(@($appsTab, $tweaksTab))

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Dock = "Fill"
    $progressBar.Height = 25
    $progressBar.Style = "Continuous"
    $progressBar.ForeColor = [System.Drawing.Color]::FromArgb(100, 149, 237)  # CornflowerBlue
    $mainPanel.Controls.Add($progressBar, 0, 1)

    $installButton = New-Object System.Windows.Forms.Button
    $installButton.Text = "🚀 Install Selected"
    $installButton.Dock = "Fill"
    $installButton.Height = 45
    $installButton.FlatStyle = "Flat"
    $installButton.BackColor = [System.Drawing.Color]::FromArgb(100, 149, 237)
    $installButton.ForeColor = [System.Drawing.Color]::White
    $installButton.FlatAppearance.BorderSize = 0
    $installButton.Font = New-Object System.Drawing.Font($form.Font, [System.Drawing.FontStyle]::Bold)
    $installButton.Add_Click({
        $installButton.Enabled = $false
        $installButton.Text = "⏳ Working..."
        $progressBar.Value = 0

        $selected = @()
        foreach ($tab in $tabControl.TabPages) {
            $folder = if ($tab.Text.Contains("Applications")) { "installs" } else { "tweaks" }
            $selected += foreach ($control in $tab.Controls) {
                if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                    @{
                        Type = $folder
                        Script = $control.Tag
                        DisplayName = $control.Text
                    }
                }
            }
        }

        if ($selected.Count -eq 0) {
            $installButton.Enabled = $true
            $installButton.Text = "🚀 Install Selected"
            return
        }

        $increment = 100 / $selected.Count
        $completed = 0

        foreach ($item in $selected) {
            $scriptPath = Join-Path $RootPath $item.Type $item.Script
                try {
                    if (Test-Path $scriptPath) {
                        Write-Host "`n=== Installing $($item.DisplayName) ===" -ForegroundColor Magenta

                            & $scriptPath *>&1 | ForEach-Object {
                                Write-Host $_
                            }

                        $completed++
                            $progressBar.Value = [math]::Min(100, $completed * $increment)
                            Write-Host "✔ Completed $($item.DisplayName)" -ForegroundColor Green
                    }
                }
            catch {
                Write-Host "❌ Error on $($item.DisplayName): $_" -ForegroundColor Red
            }
        }

        $form.Text = "WinFlux - Installation Complete"
        $installButton.Text = "✅ Done! Click to Install More"
        $installButton.BackColor = [System.Drawing.Color]::FromArgb(76, 175, 80)
        $installButton.Enabled = $true
    })

    $mainPanel.Controls.Add($installButton, 0, 2)

    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Dock = "Bottom"
    $statusLabel.Height = 20
    $statusLabel.TextAlign = "MiddleCenter"
    $statusLabel.Visible = $false
    $mainPanel.Controls.Add($statusLabel)

    $form.Add_Shown({ $form.Activate() })
    $form.ShowDialog() | Out-Null
}

function New-TabPage {
    param(
        [string]$Name,
        [array]$Items
    )

    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = $Name
    $tab.AutoScroll = $true
    $tab.Padding = New-Object System.Windows.Forms.Padding(10)
    $tab.BackColor = [System.Drawing.Color]::White

    $y = 15
    foreach ($item in $Items) {
        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.Text = $item.DisplayName
        $chk.Tag = $item.ScriptName
        $chk.Location = New-Object System.Drawing.Point(20, $y)
        $chk.AutoSize = $true
        $chk.Checked = $true
        $chk.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $tab.Controls.Add($chk)
        $y += 35
    }

    return $tab
}

function Get-InstallableItems {
    param(
        [string]$Path
    )

    $items = @()
    if (Test-Path $Path) {
        Get-ChildItem -Path $Path -Filter "*.ps1" | ForEach-Object {
            $items += @{
                DisplayName = $_.BaseName.Replace("-", " ").Replace("_", " ")
                ScriptName = $_.Name
            }
        }
    }
    return $items | Sort-Object DisplayName
}

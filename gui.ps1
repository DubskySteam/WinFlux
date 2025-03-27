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
    
    Write-Host "GUI running from: $RootPath" -ForegroundColor Yellow
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "WinFlux Setup"
    $form.Size = New-Object System.Drawing.Size(650, 600)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedSingle"

    $mainPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $mainPanel.Dock = "Fill"
    $mainPanel.RowCount = 3
    $mainPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))
    $mainPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
    $mainPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
    $form.Controls.Add($mainPanel)

    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Dock = "Fill"
    $mainPanel.Controls.Add($tabControl, 0, 0)

    $appsTab = New-TabPage -Name "Applications" -Items (Get-InstallableItems -Path "$RootPath/installs")
    $tweaksTab = New-TabPage -Name "Tweaks" -Items (Get-InstallableItems -Path "$RootPath/tweaks")
    $tabControl.Controls.Add($appsTab)
    $tabControl.Controls.Add($tweaksTab)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Dock = "Fill"
    $progressBar.Height = 20
    $progressBar.Style = "Continuous"
    $mainPanel.Controls.Add($progressBar, 0, 1)

    $installButton = New-Object System.Windows.Forms.Button
    $installButton.Text = "Install Selected"
    $installButton.Dock = "Fill"
    $installButton.Height = 40
    $installButton.Add_Click({
        $installButton.Enabled = $false
        $progressBar.Value = 0

        $selected = @()
        foreach ($tab in $tabControl.TabPages) {
            $folder = if ($tab.Text -eq "Applications") { "installs" } else { "tweaks" }
            foreach ($control in $tab.Controls) {
                if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                    $selected += @{
                        Type = $folder
                        Script = $control.Tag
                        DisplayName = $control.Text
                    }
                }
            }
        }

        if ($selected.Count -eq 0) {
            $installButton.Enabled = $true
            return
        }

        $increment = 100 / $selected.Count
        $completed = 0

        $outputBox = New-Object System.Windows.Forms.TextBox
        $outputBox.Multiline = $true
        $outputBox.ScrollBars = "Vertical"
        $outputBox.Dock = "Fill"
        $outputBox.ReadOnly = $true
        $outputBox.BackColor = [System.Drawing.Color]::Black
        $outputBox.ForeColor = [System.Drawing.Color]::Lime
        $outputBox.Font = New-Object System.Drawing.Font("Consolas", 10)
        
        $outputForm = New-Object System.Windows.Forms.Form
        $outputForm.Text = "Installation Output"
        $outputForm.Size = New-Object System.Drawing.Size(800, 400)
        $outputForm.StartPosition = "CenterScreen"
        $outputForm.Controls.Add($outputBox)
        $outputForm.Show()

        foreach ($item in $selected) {
            $scriptPath = Join-Path $RootPath $item.Type $item.Script
            try {
                if (Test-Path $scriptPath) {
                    $outputBox.AppendText("=== Working on: $($item.DisplayName) ===`r`n")
                    $form.Text = "Installing: $($item.DisplayName) ($($completed+1)/$($selected.Count))"
                    $form.Refresh()

                    $scriptOutput = & $scriptPath 2>&1 | Out-String
                    $outputBox.AppendText($scriptOutput + "`r`n")
                    
                    $completed++
                    $progressBar.Value = [math]::Min(100, $completed * $increment)
                }
            }
            catch {
                $outputBox.AppendText("[ERROR] $($item.DisplayName): $_`r`n")
            }
        }

        $form.Text = "Installation Complete"
        $installButton.Enabled = $true
        $outputBox.AppendText("=== Installation completed ===`r`n`r`n")
        $outputBox.AppendText("==============================`r`n")
        $outputBox.AppendText("=== CLOSE THIS WINDOW FIRST ==`r`n")
        $outputBox.AppendText("==============================`r`n")
    })
    $mainPanel.Controls.Add($installButton, 0, 2)

    $form.ShowDialog()
}

function New-TabPage {
    param(
        [string]$Name,
        [array]$Items
    )

    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = $Name
    $tab.AutoScroll = $true

    $y = 20
    foreach ($item in $Items) {
        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.Text = $item.DisplayName
        $chk.Tag = $item.ScriptName
        $chk.Location = New-Object System.Drawing.Point(20, $y)
        $chk.AutoSize = $true
        $chk.Checked = $true
        $tab.Controls.Add($chk)
        $y += 30
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
                DisplayName = $_.BaseName.Replace("-", " ")
                ScriptName = $_.Name
            }
        }
    }
    return $items
}

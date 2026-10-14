$ErrorActionPreference = 'Continue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Start-Transcript -Path "$here\debloat.log" -Force | Out-Null

# Runs elevated, so HKCU here is still the signed-in user (same account, just elevated)
function Set-Reg($path, $name, $value, $type = 'DWord') {
    if (-not (Test-Path $path)) { New-Item $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $name -Value $value -Type $type
}

# ---------- 1 + 2. Apps ----------
$apps = @(
    # junk
    'Microsoft.BingNews','Microsoft.BingWeather','Microsoft.BingSearch','Microsoft.GetHelp',
    'Microsoft.MicrosoftSolitaireCollection','Microsoft.MixedReality.Portal','Microsoft.People','Microsoft.SkypeApp',
    'Clipchamp.Clipchamp','Microsoft.MicrosoftOfficeHub','Microsoft.Todos','Microsoft.PowerAutomateDesktop',
    'Microsoft.WindowsFeedbackHub','Microsoft.WindowsMaps','Microsoft.Windows.DevHome','microsoft.windowscommunicationsapps',
    'Microsoft.OutlookForWindows','MSTeams','Microsoft.6365217CE6EB4','Microsoft.ZuneVideo','E046963F.LenovoCompanion',
    'MicrosoftWindows.Client.WebExperience',
    # xbox / gaming
    'Microsoft.GamingApp','Microsoft.Xbox.TCUI','Microsoft.XboxGameOverlay','Microsoft.XboxGamingOverlay',
    'Microsoft.XboxIdentityProvider','Microsoft.XboxSpeechToTextOverlay','Microsoft.Edge.GameAssist'
)
foreach ($a in $apps) {
    Get-AppxPackage -AllUsers -Name $a | ForEach-Object {
        Write-Host "REMOVE  $($_.Name)"
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    }
    # Provisioned copy = what Windows reinstalls for new users / after feature updates
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $a |
        Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
    # Leftover per-user app data
    Get-ChildItem "$env:LOCALAPPDATA\Packages" -Directory -Filter "$a`_*" -ErrorAction SilentlyContinue |
        ForEach-Object { if (-not (Get-AppxPackage -Name $a)) { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue } }
}
# Keep Widgets / Teams chat from coming back on the taskbar
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' AllowNewsAndInterests 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' TaskbarDa 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' TaskbarMn 0
# Game DVR background recording is pointless without Game Bar
Set-Reg 'HKCU:\System\GameConfigStore' GameDVR_Enabled 0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' AllowGameDVR 0

# Edge auto-start at login + startup boost
Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' | Select-Object -ExpandProperty Property |
    Where-Object { $_ -like 'MicrosoftEdgeAutoLaunch*' } |
    ForEach-Object { Write-Host "STARTUP off  $_"; Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $_ }
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' StartupBoostEnabled 0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' BackgroundModeEnabled 0

if (Test-Path 'C:\OneDriveTemp') { Write-Host 'DELETE  C:\OneDriveTemp'; Remove-Item -LiteralPath 'C:\OneDriveTemp' -Recurse -Force }

# ---------- 7. Privacy + no ads ----------
Write-Host 'TWEAK   privacy / ads'
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' AllowTelemetry 0
Set-Service DiagTrack -StartupType Disabled; Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' Enabled 0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' DisabledByGroupPolicy 1
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' TailoredExperiencesWithDiagnosticDataEnabled 0
# Stops Candy Crush & co. auto-installing, and Start/lock-screen/Settings suggestions
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' DisableWindowsConsumerFeatures 1
$cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
foreach ($n in 'SilentInstalledAppsEnabled','SystemPaneSuggestionsEnabled','SoftLandingEnabled','RotatingLockScreenOverlayEnabled',
               'PreInstalledAppsEnabled','OemPreInstalledAppsEnabled','SubscribedContent-338387Enabled','SubscribedContent-338388Enabled',
               'SubscribedContent-338389Enabled','SubscribedContent-338393Enabled','SubscribedContent-353694Enabled',
               'SubscribedContent-353696Enabled','SubscribedContent-310093Enabled') { Set-Reg $cdm $n 0 }
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement' ScoobeSystemSettingEnabled 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' Start_IrisRecommendations 0
# Bing web results in Start search
Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' DisableSearchBoxSuggestions 1
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' BingSearchEnabled 0
# Copilot + Recall
Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' TurnOffWindowsCopilot 1
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' TurnOffWindowsCopilot 1
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' ShowCopilotButton 0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' DisableAIDataAnalysis 1
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' AllowRecallEnablement 0
Get-AppxPackage -AllUsers -Name 'Microsoft.Copilot' | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

# ---------- 8. Explorer ----------
Write-Host 'TWEAK   explorer'
$adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-Reg $adv HideFileExt 0
Set-Reg $adv Hidden 1
Set-Reg $adv LaunchTo 1

# ---------- 9. Classic right-click menu ----------
Write-Host 'TWEAK   classic context menu'
Set-Reg 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' '(default)' '' 'String'

Stop-Process -Name explorer -Force   # restarts automatically and picks up the changes
Write-Host "`nDONE. Restart the PC once to apply everything."
Stop-Transcript | Out-Null

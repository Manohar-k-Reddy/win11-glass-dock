$p = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
if (-not (Test-Path $p)) { New-Item $p -Force | Out-Null }
Set-ItemProperty $p DisableWebSearch 1 -Type DWord
Set-ItemProperty $p ConnectedSearchUseWeb 0 -Type DWord
Set-ItemProperty $p AllowCloudSearch 0 -Type DWord
Set-ItemProperty $p EnableDynamicContentInWSB 0 -Type DWord
$e = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
if (-not (Test-Path $e)) { New-Item $e -Force | Out-Null }
Set-ItemProperty $e DisableSearchBoxSuggestions 1 -Type DWord

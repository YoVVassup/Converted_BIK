param([string]$Target)
if ([string]::IsNullOrEmpty($Target)) { exit 1 }
$dir = Split-Path -Parent $Target
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$h = @(0,0,0,0,0,0,0,0,0,0,0,0,0,0)
[System.IO.File]::WriteAllBytes($Target, [byte[]]$h)

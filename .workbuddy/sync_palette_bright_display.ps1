$ErrorActionPreference = 'Stop'
$taskPython = 'C:\Users\qq303\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (-not (Test-Path -LiteralPath $taskPython)) { $taskPython = (Get-Command python -ErrorAction Stop).Source }
& $taskPython (Join-Path $PSScriptRoot 'sync_palette_bright_display.py')
if ($LASTEXITCODE -ne 0) { throw '调色盘显示同步失败，停止部署。' }

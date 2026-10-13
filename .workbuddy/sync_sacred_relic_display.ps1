$ErrorActionPreference = 'Stop'
$taskPython = 'C:\Users\qq303\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (-not (Test-Path -LiteralPath $taskPython)) { $taskPython = (Get-Command python -ErrorAction Stop).Source }
& $taskPython (Join-Path $PSScriptRoot 'sync_sacred_relic_display.py')
if ($LASTEXITCODE -ne 0) { throw '圣骸整体显示同步失败，停止部署。' }

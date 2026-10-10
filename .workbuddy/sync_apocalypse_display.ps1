$ErrorActionPreference = 'Stop'
$taskPython = 'C:\Users\qq303\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (-not (Test-Path -LiteralPath $taskPython)) {
    $taskCommand = Get-Command python -ErrorAction Stop
    $taskPython = $taskCommand.Source
}
& $taskPython (Join-Path $PSScriptRoot 'sync_apocalypse_display.py')
if ($LASTEXITCODE -ne 0) { throw '启示录显示同步失败，停止部署。' }

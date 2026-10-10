$ErrorActionPreference = 'Stop'
$taskWorkspace = [IO.Path]::GetFullPath((Split-Path $PSScriptRoot))
$taskManifestPath = Join-Path $PSScriptRoot 'aurora_binding.json'
$taskManifest = Get-Content -LiteralPath $taskManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$taskEditor = Get-Content -LiteralPath $taskManifest.display_editor -Raw -Encoding UTF8 | ConvertFrom-Json
if ($taskEditor.meta.model_format -ne 'java_block' -or -not $taskEditor.display) { throw '请先保存 Java 格式的整体显示调整 bbmodel。' }
$taskRpRoot = [IO.Path]::GetFullPath((Join-Path $taskWorkspace 'sweetdream_rp'))
$taskCount = 0
foreach ($taskRel in $taskManifest.source_rp_files) {
    if ($taskRel -notlike 'assets/sweetdream/models/item/aurora_dream*.json') { continue }
    $taskPath = [IO.Path]::GetFullPath((Join-Path $taskRpRoot $taskRel))
    if (-not $taskPath.StartsWith(($taskRpRoot + '\'), [StringComparison]::OrdinalIgnoreCase)) { throw '模型路径越界。' }
    $taskModel = Get-Content -LiteralPath $taskPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $taskModel.display = $taskEditor.display
    [IO.File]::WriteAllText($taskPath, ($taskModel | ConvertTo-Json -Depth 100 -Compress), [Text.UTF8Encoding]::new($false))
    $taskCount++
}
if ($taskCount -lt 2) { throw '未找到整体模型和动画部件。' }
$taskExample = Join-Path (Split-Path $taskManifest.display_editor) '显示调整示例\assets\auroradream\models\item\aurora_dream.json'
$taskExampleModel = Get-Content -LiteralPath $taskExample -Raw -Encoding UTF8 | ConvertFrom-Json
$taskExampleModel.display = $taskEditor.display
[IO.File]::WriteAllText($taskExample, ($taskExampleModel | ConvertTo-Json -Depth 100 -Compress), [Text.UTF8Encoding]::new($false))
Write-Output ('已同步总体握姿至 ' + $taskCount + ' 份模型，几何未变更。')

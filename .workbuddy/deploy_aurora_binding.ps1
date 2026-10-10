$ErrorActionPreference = 'Stop'
$taskWorkspace = [IO.Path]::GetFullPath((Split-Path $PSScriptRoot))
$taskGame = [IO.Path]::GetFullPath('D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10')
$taskSave = [IO.Path]::GetFullPath((Join-Path $taskGame 'saves\测试包体'))
if (-not (Test-Path -LiteralPath (Join-Path $taskSave 'level.dat'))) { throw '目标存档缺少 level.dat。' }
$taskManifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'aurora_binding.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$taskPairs = @(
    @{ Source = (Join-Path $taskWorkspace 'sweetdream_rp'); Target = (Join-Path $taskGame 'resourcepacks\sweetdream_rp'); Files = $taskManifest.source_rp_files },
    @{ Source = (Join-Path $taskWorkspace 'sweetdream'); Target = (Join-Path $taskSave 'datapacks\sweetdream'); Files = $taskManifest.source_dp_files }
)
$taskAllowed = @(
    [IO.Path]::GetFullPath((Join-Path $taskGame 'resourcepacks\sweetdream_rp')),
    [IO.Path]::GetFullPath((Join-Path $taskSave 'datapacks\sweetdream'))
)
$taskBackup = Join-Path $PSScriptRoot 'backup\aurora-game-20261010'
$taskCount = 0
foreach ($taskPair in $taskPairs) {
    $taskTargetRoot = [IO.Path]::GetFullPath($taskPair.Target)
    if ($taskAllowed -notcontains $taskTargetRoot) { throw '部署目标未列入允许目录。' }
    if (-not (Test-Path -LiteralPath (Join-Path $taskTargetRoot 'pack.mcmeta'))) { throw '目标包缺少 pack.mcmeta。' }
    foreach ($taskRel in $taskPair.Files) {
        $taskSource = [IO.Path]::GetFullPath((Join-Path $taskPair.Source $taskRel))
        $taskTarget = [IO.Path]::GetFullPath((Join-Path $taskTargetRoot $taskRel))
        if (-not $taskSource.StartsWith(([IO.Path]::GetFullPath($taskPair.Source) + '\'), [StringComparison]::OrdinalIgnoreCase)) { throw '源路径越界。' }
        if (-not $taskTarget.StartsWith(($taskTargetRoot + '\'), [StringComparison]::OrdinalIgnoreCase)) { throw '目标路径越界。' }
        $taskParent = Split-Path $taskTarget
        $taskInspect = $taskParent
        while ($taskInspect -and $taskInspect.StartsWith($taskGame, [StringComparison]::OrdinalIgnoreCase)) {
            if (Test-Path -LiteralPath $taskInspect) {
                if ((Get-Item -LiteralPath $taskInspect).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw '目标路径包含重解析点。' }
            }
            $taskInspect = Split-Path $taskInspect
        }
        if (Test-Path -LiteralPath $taskTarget) {
            if ((Get-Item -LiteralPath $taskTarget).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw '目标文件是重解析点。' }
            $taskArchive = Join-Path (Join-Path $taskBackup (Split-Path $taskPair.Source -Leaf)) $taskRel
            if (-not (Test-Path -LiteralPath $taskArchive)) {
                $null = New-Item -ItemType Directory -Path (Split-Path $taskArchive) -Force
                Copy-Item -LiteralPath $taskTarget -Destination $taskArchive
            }
        }
        $null = New-Item -ItemType Directory -Path $taskParent -Force
        Copy-Item -LiteralPath $taskSource -Destination $taskTarget -Force
        if ((Get-FileHash -LiteralPath $taskSource).Hash -ne (Get-FileHash -LiteralPath $taskTarget).Hash) { throw ('文件哈希不一致：' + $taskRel) }
        $taskCount++
    }
}
$taskResult = @{ files_verified = $taskCount; resource_files = $taskManifest.source_rp_files.Count; datapack_files = $taskManifest.source_dp_files.Count; target_game = $taskGame; target_save = $taskSave; deployed_at = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); game_tested = $false }
$taskResult | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'aurora_deployment.json') -Encoding UTF8
Write-Output ('极光与幻梦 739 元素模型和动画已部署，' + $taskCount + ' 个文件 SHA-256 校验一致。')
Write-Output '资源包按 F3+T 重载，数据包执行 /reload；新增模型建议退出世界再进入。'

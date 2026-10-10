$ErrorActionPreference = 'Stop'
$taskSource = [IO.Path]::GetFullPath((Split-Path $PSScriptRoot))
$taskGame = [IO.Path]::GetFullPath('D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10')
$taskSave = [IO.Path]::GetFullPath((Join-Path $taskGame 'saves\测试包体'))
if (-not (Test-Path -LiteralPath (Join-Path $taskSave 'level.dat'))) { throw '目标存档缺少 level.dat，停止部署。' }
$taskSync = Join-Path $PSScriptRoot 'sync_apocalypse_display.ps1'
if (Test-Path -LiteralPath $taskSync) { & $taskSync }
$taskPairs = @(
    @{Source = (Join-Path $taskSource 'manacore-1.0.0'); Target = (Join-Path $taskSave 'datapacks\manacore-1.0.0')},
    @{Source = (Join-Path $taskSource 'sweetdream'); Target = (Join-Path $taskSave 'datapacks\sweetdream')},
    @{Source = (Join-Path $taskSource 'sweetdream_rp'); Target = (Join-Path $taskGame 'resourcepacks\sweetdream_rp')}
)
# 镜像删除仅限明确列出的三个包，不触碰世界数据及其他资源包/数据包。
$taskAllow = @(
    [IO.Path]::GetFullPath((Join-Path $taskSave 'datapacks\manacore-1.0.0')),
    [IO.Path]::GetFullPath((Join-Path $taskSave 'datapacks\sweetdream')),
    [IO.Path]::GetFullPath((Join-Path $taskGame 'resourcepacks\sweetdream_rp'))
)
foreach ($taskPair in $taskPairs) {
    $taskTarget = [IO.Path]::GetFullPath($taskPair.Target)
    if ($taskAllow -notcontains $taskTarget) { throw ('不允许的镜像目标：' + $taskTarget) }
    if (-not (Test-Path -LiteralPath (Join-Path $taskPair.Source 'pack.mcmeta'))) { throw '源包缺少 pack.mcmeta。' }
    if (Test-Path -LiteralPath $taskTarget) {
        if ((Get-Item -LiteralPath $taskTarget).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw '目标是重解析点，停止镜像。' }
    }
    $null = & robocopy $taskPair.Source $taskTarget /MIR /NFL /NDL /NJH /NJS /NP
    if ($LASTEXITCODE -ge 8) { throw ('复制失败：' + $taskTarget + '，代码 ' + $LASTEXITCODE) }
    Write-Output ('已同步：' + $taskTarget)
}
# 按 SHA-256 检查本次接入的文件及父显示入口实际落到游戏副本。
$taskFiles = @(
    @{Base='sweetdream_rp'; Rel='assets\angelcore\items\axe.json'},
    @{Base='sweetdream_rp'; Rel='assets\angelcore\models\item\axe.json'},
    @{Base='sweetdream_rp'; Rel='assets\angelcore\models\item\parts\body.json'},
    @{Base='sweetdream_rp'; Rel='assets\coldcrow\models\item\crossbow.json'},
    @{Base='sweetdream_rp'; Rel='assets\sweetdream\models\item\apocalypse.json'},
    @{Base='sweetdream_rp'; Rel='assets\sweetdream\models\item\angel_beam.json'},
    @{Base='sweetdream_rp'; Rel='assets\sweetdream\models\item\fr_beam.json'},
    @{Base='sweetdream_rp'; Rel='assets\sweetdream\models\item\domain.json'},
    @{Base='sweetdream_rp'; Rel='assets\sweetdream\textures\item\thunder_domain_v2.png'},
    @{Base='sweetdream_rp'; Rel='assets\sweetdream\textures\item\light_origin_v3.png'},
    @{Base='sweetdream_rp'; Rel='assets\sweetdream\textures\item\light_origin_v3.png.mcmeta'},
    @{Base='sweetdream'; Rel='data\sweetdream\function\equipment\axe\thunderclap\domain_fx.mcfunction'},
    @{Base='sweetdream'; Rel='data\sweetdream\function\equipment\staff\final_revelation\beam_new.mcfunction'},
    @{Base='sweetdream'; Rel='data\sweetdream\function\equipment\staff\final_revelation\beam_go.mcfunction'},
    @{Base='sweetdream'; Rel='data\sweetdream\function\visual\tick.mcfunction'},
    @{Base='sweetdream'; Rel='data\sweetdream\function\equipment\axe\angel_core\visual\beam_anim.mcfunction'},
    @{Base='sweetdream_rp'; Rel='assets\sail\models\item\staff.json'},
    @{Base='sweetdream'; Rel='data\minecraft\tags\function\load.json'},
    @{Base='sweetdream'; Rel='data\minecraft\tags\function\tick.json'},
    @{Base='sweetdream'; Rel='data\sweetdream\item_modifier\angel_core_visual.json'},
    @{Base='sweetdream'; Rel='data\sweetdream\function\equipment\axe\angel_core\give.mcfunction'},
    @{Base='sweetdream'; Rel='data\sweetdream\function\equipment\axe\angel_core\visual\tick.mcfunction'}
)
foreach ($taskFile in $taskFiles) {
    $taskPair = $taskPairs | Where-Object { (Split-Path $_.Source -Leaf) -eq $taskFile.Base }
    $taskA = Join-Path $taskPair.Source $taskFile.Rel
    $taskB = Join-Path $taskPair.Target $taskFile.Rel
    if ((Get-FileHash -LiteralPath $taskA).Hash -ne (Get-FileHash -LiteralPath $taskB).Hash) { throw ('部署校验失败：' + $taskFile.Rel) }
}
$taskAngelSource = Join-Path $taskSource 'sweetdream_rp\assets\angelcore'
$taskAngelTarget = Join-Path $taskGame 'resourcepacks\sweetdream_rp\assets\angelcore'
$taskVerified = 0
foreach ($taskFile in Get-ChildItem -LiteralPath $taskAngelSource -File -Recurse) {
    $taskRel = $taskFile.FullName.Substring($taskAngelSource.Length).TrimStart('\')
    $taskDest = Join-Path $taskAngelTarget $taskRel
    if ((Get-FileHash -LiteralPath $taskFile.FullName).Hash -ne (Get-FileHash -LiteralPath $taskDest).Hash) { throw ('天使核心资源校验失败：' + $taskRel) }
    $taskVerified++
}
Write-Output ('天使核心 ' + $taskVerified + ' 个资源文件及全部接入入口哈希一致。')
exit 0

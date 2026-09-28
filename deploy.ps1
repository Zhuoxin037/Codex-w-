# ============================================================
#  一键把 manacore-1.0.0 和 sweetdream 部署到存档的 datapacks
# ------------------------------------------------------------
#  用法:
#    1) 双击「部署到存档.bat」                      -> 默认存档 sweetdream_test
#    2) 把别的「存档文件夹」拖到「部署到存档.bat」上 -> 部署到那个存档
#  注意: 拖进来的必须是【存档文件夹】(里面有 level.dat 的那个),
#        不是里面的 datapacks 文件夹。
#  原理: robocopy /MIR 把两个包镜像过去 —— 源里删掉的文件, 目标里也会跟着删,
#        不会留下旧版本的残留函数。镜像范围只限那两个包自己的文件夹。
# ============================================================

$ErrorActionPreference = 'Stop'

$Src = $PSScriptRoot
$DefaultSave = 'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\saves\sweetdream_test'

$Save = if ($args.Count -ge 1 -and $args[0]) { [string]$args[0] } else { $DefaultSave }
$Save = $Save.TrimEnd('\')

Write-Host ''
Write-Host "  源目录: $Src"
Write-Host "  存档  : $Save"
Write-Host ''

if (-not (Test-Path -LiteralPath (Join-Path $Save 'level.dat'))) {
	Write-Host '  [错误] 这不像是一个存档文件夹(里面没有 level.dat)。' -ForegroundColor Red
	Write-Host '         请把【存档文件夹】拖到「部署到存档.bat」上, 或者直接双击用默认存档。'
	Write-Host ''
	Read-Host '按回车关闭'
	exit 1
}

$pairs = @(
	@{ Name = 'manacore-1.0.0'; Src = (Join-Path $Src 'manacore-1.0.0') },
	@{ Name = 'sweetdream';     Src = (Join-Path $Src 'sweetdream') }
)

foreach ($p in $pairs) {
	if (-not (Test-Path -LiteralPath $p.Src)) {
		Write-Host ("  [错误] 源目录里找不到 " + $p.Name) -ForegroundColor Red
		Read-Host '按回车关闭'
		exit 1
	}
	$dst = Join-Path (Join-Path $Save 'datapacks') $p.Name
	Write-Host ("  复制 " + $p.Name + " ...")
	# /MIR = 镜像; 范围只限这个包自己的文件夹, 不会碰别的数据包
	$null = robocopy $p.Src $dst /MIR /NFL /NDL /NJH /NJS /NP
	if ($LASTEXITCODE -ge 8) {
		Write-Host ("  [错误] 复制 " + $p.Name + " 失败 (robocopy 代码 " + $LASTEXITCODE + ")") -ForegroundColor Red
		Read-Host '按回车关闭'
		exit 1
	}
}

Write-Host ''
Write-Host '  完成。' -ForegroundColor Green
Write-Host ''
Write-Host '  下一步: 进游戏执行  /reload'
Write-Host ''
Read-Host '按回车关闭'

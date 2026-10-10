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
$DefaultSave = 'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\saves\测试包体'

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

# --- 部署前的"显示同步"(O09: 必需, 不许静默跳过) ---
#   ★ 为什么是**必需**而不是"有就跑"：
#     启示录靠各部件 display 合成整体握姿、调色盘要同步提色动画 —— 不跑这两步,
#     数据包/资源包还是"能装", 但产物**悄悄不一样**(书页错位 / 提色动画丢失),
#     而且不报任何错。发布产物绝不能取决于"本机恰好有没有这个脚本"。
#   ★ 脚本本体在 .workbuddy\ 下, 已随 O09 纳入版本控制(clone 即得)。
function Invoke-RequiredSync([string]$Name) {
	$p = Join-Path $Src ('.workbuddy\' + $Name)
	if (-not (Test-Path -LiteralPath $p)) {
		Write-Host ("  [错误] 缺少必需的同步脚本 .workbuddy\" + $Name) -ForegroundColor Red
		Write-Host '         它是部署产物的必要组成(O09), 不能跳过。请先恢复该脚本再重试。'
		Read-Host '按回车关闭'
		exit 1
	}
	& $p
	if ($LASTEXITCODE -ne 0) {
		Write-Host ("  [错误] 同步脚本 " + $Name + " 执行失败 (代码 " + $LASTEXITCODE + ")") -ForegroundColor Red
		Read-Host '按回车关闭'
		exit 1
	}
}

# 启示录翻页使用各部件 display；部署前合成整体握姿，避免仅移动书壳而书页错位。
Invoke-RequiredSync 'sync_apocalypse_display.ps1'
# 调色盘整体握姿与提色动画同步。
Invoke-RequiredSync 'sync_palette_bright_display.ps1'

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

# --- 资源包(图标 / 以后的武器模型) ---
#   数据包只能改逻辑, 贴图/图标这类东西必须走资源包。这里把它镜像到
#   游戏目录的 resourcepacks\ 下; 进游戏后在「选项 -> 资源包」启用一次即可
#   (每个存档启用一次, 之后一直生效)。
#   注意: 这个整合包开了版本隔离, 所以游戏目录是「版本文件夹」而不是 .minecraft;
#   从存档路径往上两层正好是版本文件夹。
#   ★ 2026-10-10(F20 修): 目标改成本实例 options.txt 里**实际加载**的那一份 ——
#     `sweetdream_rp_完整版`。原来固定抄老包 `sweetdream_rp`, 而游戏根本没启用它
#     ⇒ 只改老包再一键部署, 游戏外观毫无变化(工作区与游戏不一致)。
#   ⚠️ `sweetdream_rp_完整版` 是**合并产物**: 改完老包/覆盖层后先
#      `python .workbuddy\build_full_pack.py` 重建它, 或直接
#      `python .workbuddy\build_full_pack.py --deploy`(重建+部署一步到位)。
$RpSrc = Join-Path $Src 'sweetdream_rp_完整版'
$RpName = 'sweetdream_rp_完整版'
if (Test-Path -LiteralPath $RpSrc) {
	try {
		$GameDir = Split-Path (Split-Path $Save)
		$RpDst = Join-Path $GameDir ('resourcepacks\' + $RpName)
		Write-Host ('  复制 ' + $RpName + ' -> resourcepacks ...')
		$null = robocopy $RpSrc $RpDst /MIR /NFL /NDL /NJH /NJS /NP
		if ($LASTEXITCODE -ge 8) {
			Write-Host ('  [警告] 资源包复制失败 (robocopy 代码 ' + $LASTEXITCODE + '), 请手动把它放进 resourcepacks') -ForegroundColor Yellow
		}
	} catch {
		Write-Host ('  [警告] 算不出游戏目录, 请手动把 ' + $RpName + ' 放进 resourcepacks') -ForegroundColor Yellow
	}
}

Write-Host ''
Write-Host '  完成。' -ForegroundColor Green
Write-Host ''
Write-Host '  下一步:'
Write-Host '    1) 进游戏执行  /reload'
Write-Host '    2) 第一次装的话, 去「选项 -> 资源包」把 sweetdream_rp_完整版 启用(否则生物头顶只显示翻译键原文)'
Write-Host '    3) 改过资源包的话按 F3+T 重载资源包(/reload 不重载资源包)'
Write-Host ''
Read-Host '按回车关闭'

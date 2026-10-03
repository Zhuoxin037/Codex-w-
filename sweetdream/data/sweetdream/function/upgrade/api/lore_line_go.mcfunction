# ============================================================
# sweetdream:upgrade/api/lore_line_go —— 是最高 tier 就渲染一行(宏 {id,ser})
# ------------------------------------------------------------
# 【显示的样式】和包里其它 lore 对齐:
#     "  · " (dark_gray) + 全名 (yellow) + 备注 (gray)
#   全名 / 备注都从定义表的 label / note 取, 不用在命令里手抄。
# ============================================================

scoreboard players set #up_b zx.meta 0
$execute store result score #up_b zx.meta run data get storage zx:work mkt."$(ser)"
execute unless score #up_t zx.meta >= #up_b zx.meta run return 0

$data modify storage zx:work mk.lab set from storage zx:config updef."$(id)".label
$data modify storage zx:work mk.note set from storage zx:config updef."$(id)".note
function sweetdream:station/api/lore_render with storage zx:work mk

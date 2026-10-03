# ============================================================
# sweetdream:upgrade/api/lore_line —— 一条升级要不要显示出来(宏 {id})
# ------------------------------------------------------------
# 【谁调用它】station/api/lore_refresh 的第二遍
# 【判据】自己的 tier 是**本系列里最高的**才显示 —— α/β/Ω 同装时只报 Ω,
#   不然 "+20 / +30 / +40" 三行并排会被读成 +90。
# ============================================================

scoreboard players set #up_t zx.meta 0
$execute store result score #up_t zx.meta run data get storage zx:config updef."$(id)".tier
$data modify storage zx:work mk.ser set from storage zx:config updef."$(id)".series
function sweetdream:upgrade/api/lore_line_go with storage zx:work mk

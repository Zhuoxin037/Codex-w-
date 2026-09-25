# ------------------------------------------------------------
# internal/formation/remove_scan —— 设置遍历模式并启动全局删除
# 【作用】ctrl.mode = "formation_remove_all" -> 每个玩家都会被要求删掉
#         ctrl.arg 指定的术阵(有就删, 没有就跳过)。
# 【用途】"强制删除术阵"(管理员清场 / 术阵被全局驱散)。
# ------------------------------------------------------------
scoreboard players set #mode manacore.meta 3
function manacore:internal/index/foreach

# ------------------------------------------------------------
# internal/formation/find_scan —— 设置遍历模式并启动全局扫描
# 【作用】ctrl.mode = "formation_find" -> index/foreach 逐槽调用 find_owner。
# 【注意】调用前 ctrl.arg 必须已填好目标 id, 否则什么都不会命中。
# ------------------------------------------------------------
scoreboard players set #mode manacore.meta 4
function manacore:internal/index/foreach

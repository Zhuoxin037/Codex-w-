# ============================================================
# sweetdream:upgrade/api/lore_mark —— 记下"本系列出现过的最高 tier"(宏 {id})
# ------------------------------------------------------------
# 【谁调用它】station/api/lore_refresh 的第一遍扫描, 每条升级一次
# 【为什么要有这一层】系列名 series 要从定义表里取, 取出来之后才能把它
#   当作**路径的一部分**(zx:work mkt."<系列名>") —— 而拼路径只能用宏。
#   宏的入参在调用那一刻就定死了, 所以"先读 series、再按它拼路径"
#   必须拆成两个函数。
# ============================================================

scoreboard players set #up_t zx.meta 0
$execute store result score #up_t zx.meta run data get storage zx:config updef."$(id)".tier
$data modify storage zx:work mk.ser set from storage zx:config updef."$(id)".series
function sweetdream:upgrade/api/lore_mark_go with storage zx:work mk

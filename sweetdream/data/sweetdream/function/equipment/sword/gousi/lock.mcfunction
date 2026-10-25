# ============================================================
# sweetdream:equipment/sword/gousi/lock —— 锁 8 格内最近的一个目标（宏）
# ------------------------------------------------------------
# 【执行者】玩家（已在 `execute at @s` 里）
# 【宏参数】sweetdream:work gs {own} = 玩家 UUID[0]
# 【标记】给目标挂 zx.gs_<own>；选不到任何目标就返回失败（返回值给 cast 判）
# ============================================================
$tag @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=nearest,limit=1] add zx.gs_$(own)
$execute unless entity @e[tag=zx.gs_$(own),limit=1] run return fail
$execute at @e[tag=zx.gs_$(own),limit=1] run particle minecraft:end_rod ~ ~0.8 ~ 0.3 0.4 0.3 0.02 16 normal
$execute at @e[tag=zx.gs_$(own),limit=1] run particle minecraft:witch ~ ~0.8 ~ 0.3 0.4 0.3 0.01 10 normal

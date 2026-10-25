# ============================================================
# sweetdream:equipment/sword/gousi/miss —— 没拉到位（宏）
# ------------------------------------------------------------
# 【执行者】玩家
# 【宏参数】sweetdream:work gs {own}
# 【结算】只造成 最大魔力值 ×0.04，不给 zx.mm_add 加成，不给缓慢Ⅱ
# 【目标可能已经死了 / 不存在】那种情况就只清状态，一点伤害也不打。
# ============================================================
function sweetdream:lib/uuid
execute if data storage zx:data self{ok:1b} run function sweetdream:equipment/sword/gousi/miss_hit with storage zx:work gs

$execute at @e[tag=zx.gs_$(own),limit=1] run particle minecraft:smoke ~ ~0.8 ~ 0.3 0.4 0.3 0.01 10 normal
$tag @e[tag=zx.gs_$(own)] remove zx.gs_$(own)
scoreboard players set @s zx.gs_st 0
scoreboard players set @s zx.gs_own 0

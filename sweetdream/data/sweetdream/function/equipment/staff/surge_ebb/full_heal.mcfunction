# ============================================================
# sweetdream:equipment/staff/surge_ebb/full_heal —— 潮涌，潮枯：回满生命值
# ------------------------------------------------------------
# 【执行者】玩家
# 【怎么回满】把"缺多少整点"交给 lib/heal（压上限 → 顶满 → 跨拍撤上限）。
#   不走 `effect instant_health` —— 那一发没有天花板，会顺手把"上限被别的装备
#   压低"的情况一起冲掉（lib/heal 头注释里 2026-10-16 的教训）。
# ============================================================

function sweetdream:lib/max_health_score
scoreboard players operation #se_miss zx.meta = #max_hp zx.meta
scoreboard players operation #se_miss zx.meta -= @s zx.hp_c
execute if score #se_miss zx.meta matches ..0 run return 0
scoreboard players operation #se_miss zx.meta /= #1000 zx.meta
execute if score #se_miss zx.meta matches ..0 run scoreboard players set #se_miss zx.meta 1
scoreboard players operation #heal_pt zx.meta = #se_miss zx.meta
function sweetdream:lib/heal

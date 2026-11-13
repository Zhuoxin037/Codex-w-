# @s = 持有长祝的玩家, 每 2 秒一跳。
# 满血 -> 改为"下一次技能伤害 +8%(可叠加)"; 未满 -> 恢复 4% 最大生命值。
# 先把下一跳时刻推走, 满血分支 return 才不会导致每刻重复结算。
scoreboard players operation @s zx.lb_next = #now manacore.meta
scoreboard players add @s zx.lb_next 40
function sweetdream:lib/hp_pct
execute if score #hp_p100 zx.meta matches 10000 run function sweetdream:equipment/armor/long_blessing/buff
execute if score #hp_p100 zx.meta matches 10000 run return 0
function sweetdream:lib/max_health_score
scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
scoreboard players set #mp_mul zx.meta 40
function sweetdream:lib/math/mul_permille
scoreboard players operation @s zx.lb_hacc += #mp_out zx.meta
execute if score @s zx.lb_hacc matches 1000.. run function sweetdream:equipment/armor/long_blessing/heal_out

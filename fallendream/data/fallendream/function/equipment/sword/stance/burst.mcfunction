# ============================================================
# fallendream:equipment/sword/stance/burst —— 结算伤害一次投给 3 格内全部生物
# ------------------------------------------------------------
# 【执行者】玩家(施法者)   【入参】zx:work stc.dmg（整点 double 伤害）
# 【投递】a.num → lib/num/plain → internal/damage/with_from
#   target 用 @e[type=!#fallendream:no_damage,distance=0.1..3]（非玩家生物，排除自身）
# ============================================================

data modify storage zx:work a set value {target:"@e[type=!#fallendream:no_damage,distance=0.1..3]",damage:0.0,type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work stc.dmg
data modify storage zx:work a.num set from storage zx:work stc.dmg
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
function fallendream:lib/num/plain
execute at @s run function fallendream:internal/attack/submit_skill

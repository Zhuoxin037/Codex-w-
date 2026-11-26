# ============================================================
# fallendream:equipment/sword/wound_stack/fire —— 把冻结的固定值一次投给全部目标
# ------------------------------------------------------------
# 【执行者】施法者(玩家)   【入参】zx:work wsk.dmg（整点 double 伤害）
# 【投递】a.num → lib/num/plain → internal/damage/with_from（detach 固定值样板）
#   type 走 zx:config damage_type（默认 fallendream:skill）；uncapped:1b 绕开无敌帧
# ============================================================

execute unless entity @e[tag=zx.wsk_t,distance=0..,limit=1] run return 0

data modify storage zx:work a set value {target:"@e[tag=zx.wsk_t,distance=0..]",damage:0.0,type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work wsk.dmg
data modify storage zx:work a.num set from storage zx:work wsk.dmg
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
function fallendream:lib/num/plain
execute at @s run function fallendream:internal/attack/submit_skill

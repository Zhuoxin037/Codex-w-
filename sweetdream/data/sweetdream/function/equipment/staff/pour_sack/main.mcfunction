# ============================================================
# sweetdream:equipment/staff/pour_sack/main —— 主目标：消耗÷5 固定伤害
# ============================================================
data modify storage zx:work a set value {fixed:1b,target:"@s",type:"minecraft:player_attack"}
data modify storage zx:work a.num set value 0.0
execute store result storage zx:work a.num double 1.0 run scoreboard players get #ps_d zx.meta
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work ps.u0
data modify storage zx:work a.u1 set from storage zx:work ps.u1
data modify storage zx:work a.u2 set from storage zx:work ps.u2
data modify storage zx:work a.u3 set from storage zx:work ps.u3
function sweetdream:internal/damage/with_from with storage zx:work a

execute at @s run particle minecraft:crit ~ ~1 ~ 0.3 0.4 0.3 0 10 normal

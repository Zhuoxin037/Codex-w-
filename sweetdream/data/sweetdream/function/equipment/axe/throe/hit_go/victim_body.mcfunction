$execute unless entity $(vx_uuid) run return 0

scoreboard players add @s zx.j_orb 0
execute unless score @s zx.j_orb matches 1.. run return 0

# ---------- 第一段：单体追加 + 易伤 ----------
scoreboard players remove @s zx.j_orb 1
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
$data modify storage zx:work a set value {target:"$(vx_uuid)",type:"sweetdream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
execute unless data storage zx:work a.s2_b_num run data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# 易伤 2 秒（40 刻）
$scoreboard players operation $(vx_uuid) zx.pn_until = #now manacore.meta
$scoreboard players add $(vx_uuid) zx.pn_until 40
$tag $(vx_uuid) add zx.pn_vul
$execute as $(vx_uuid) at @s run function sweetdream:equipment/axe/throe/watch_init

# ---------- 第二段：范围追加 + 轻微吸引 ----------
execute unless score @s zx.j_orb matches 1.. run return 0
scoreboard players remove @s zx.j_orb 1
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work a set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",type:"sweetdream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
execute unless data storage zx:work a.s2_b_num run data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function sweetdream:lib/num/plain
$execute at $(vx_uuid) run function sweetdream:internal/damage/with_from with storage zx:work a

# 向被命中的那只轻微吸引（0.75 格，遇障碍即停）
$execute at $(vx_uuid) run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.pn_v
$execute as @e[tag=zx.pn_v,distance=0..] at @s facing entity $(vx_uuid) feet positioned ^ ^ ^0.75 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
tag @e[tag=zx.pn_v,distance=..64] remove zx.pn_v

$tag $(vx_uuid) remove zx.victim

execute unless score @s zx.nr_finish matches 1.. run return 0
execute if score @s zx.nr_finish > #now manacore.meta run return 0
scoreboard players set @s zx.nr_finish 0
execute unless score @s zx.job matches 2 run return 0
scoreboard players operation #nr_mul zx.meta = @s zx.nr_count
scoreboard players set #nr_75 zx.meta 75
scoreboard players operation #nr_mul zx.meta *= #nr_75 zx.meta
scoreboard players add #nr_mul zx.meta 200
function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",attack_mul:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.attack_mul double .01 run scoreboard players get #nr_mul zx.meta
function manacore:api/damage/calc
tag @e[tag=zx.nr_finish_target,distance=0..] remove zx.nr_finish_target
tag @e[type=!#fallendream:no_damage,distance=..4,sort=nearest,limit=5] add zx.nr_finish_target
data modify storage zx:work a set value {target:"@e[tag=zx.nr_finish_target,distance=0..]",type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_skill
tag @e[tag=zx.nr_finish_target,distance=0..] remove zx.nr_finish_target
scoreboard players set #thp_v zx.meta 20
scoreboard players add @s zx.thp 0
scoreboard players operation #thp_v zx.meta += @s zx.thp
function fallendream:lib/thp/set

tag @s add zx.s2_deer_caster
scoreboard players set @s zx.s2_stage 2
scoreboard players operation @s zx.s2_stage_end = #now manacore.meta
scoreboard players add @s zx.s2_stage_end 40
function fallendream:batch21/shape/prepare
execute as @e[type=!#fallendream:no_damage,distance=..4] run function fallendream:batch21/shape/cone
function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work a set value {target:"@e[tag=zx.s2_hit,distance=..4]",type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_skill
execute as @e[tag=zx.s2_hit,distance=..4] at @s facing entity @a[tag=zx.s2_deer_caster,limit=1] feet rotated ~ 0 run function fallendream:equipment/axe/chase_deer/push
tag @e[tag=zx.s2_hit,distance=..10] remove zx.s2_hit
particle minecraft:sweep_attack ^ ^1 ^2 1.5 .2 1.5 0 5 force

tag @s remove zx.s2_deer_caster

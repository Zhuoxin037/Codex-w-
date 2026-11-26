scoreboard players set @s zx.s2_stage 0
function fallendream:batch21/shape/prepare
execute as @e[type=!#fallendream:no_damage,distance=..9] run function fallendream:batch21/shape/line
function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",attack_mul:6.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work s2_deer_damage set from storage manacore:out r.damage
data modify storage zx:work s2_b_s2_deer_damage set value {n:0,d:1}
data modify storage zx:work s2_b_s2_deer_damage set from storage manacore:out r.s2_b_damage
scoreboard players operation #s2_deer_req zx.meta = @s zx.s2_deer_max
scoreboard players set #s2_five zx.meta 5
scoreboard players operation #s2_deer_req zx.meta /= #s2_five zx.meta
data modify storage zx:work a set value {target:"@e[tag=zx.s2_hit,distance=..9]",type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute if score @s zx.s2_loss >= #s2_deer_req zx.meta run data modify storage zx:work a.type set value "fallendream:true_damage"
execute if score @s zx.s2_loss >= #s2_deer_req zx.meta run effect give @e[tag=zx.s2_hit,distance=..9] minecraft:weakness 3 1 true
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage zx:work s2_deer_damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage zx:work s2_b_s2_deer_damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_skill
tag @e[tag=zx.s2_hit,distance=..10] remove zx.s2_hit
execute rotated ~ 0 positioned ^ ^1 ^4 run particle minecraft:sweep_attack ~ ~ ~ 0 0 3 0 6 force

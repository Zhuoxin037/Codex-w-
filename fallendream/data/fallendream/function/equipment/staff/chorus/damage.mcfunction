function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
execute store result score #mp_src zx.meta run data get storage manacore:out r.damage 1000
scoreboard players operation #mp_mul zx.meta = #chorus_mul zx.meta
function fallendream:lib/math/mul_permille
data modify storage zx:work a set value {target:"@e[type=!#fallendream:no_damage,distance=..3]",type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute if score #chorus_final zx.meta matches 1 run data modify storage zx:work a.chorus_final set value 1b
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
execute store result storage zx:work a.num double 0.001 run scoreboard players get #mp_out zx.meta
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_skill

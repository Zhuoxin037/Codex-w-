scoreboard players remove @s zx.et_fox 4
data modify storage manacore:in arg set value {uuid:"",other_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work a set value {target:"@e[type=!#fallendream:no_damage,distance=..3]",type:"fallendream:skill",u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_skill
execute if score @s zx.job matches 1 run function fallendream:profession/mage/add_orb
execute if score @s zx.job matches 2 run function fallendream:profession/berserker/attack
particle minecraft:flame ~ ~1 ~ 1.0 0.3 1.0 0.03 25 normal

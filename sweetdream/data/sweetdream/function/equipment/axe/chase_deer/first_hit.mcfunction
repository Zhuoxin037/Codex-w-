function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work a set value {target:"@e[tag=zx.s2_deer_target,distance=..1.3,limit=1]",type:"sweetdream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
particle minecraft:sweep_attack ~ ~1 ~ 0 0 0 0 1 force

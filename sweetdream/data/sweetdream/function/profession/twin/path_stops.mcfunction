execute as @e[tag=zx.j_path_v,distance=0..30,scores={zx.j_ess=1..}] run scoreboard players set @s zx.j_ess 0
function sweetdream:lib/timestop {target:"@e[tag=zx.j_path_v,distance=0..30]",ticks:20}
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work jdelay set value {num:0.0,type:"sweetdream:true_damage",u0:0,u1:0,u2:0,u3:0,count:1}
data modify storage zx:work jdelay.num set from storage manacore:out r.damage
execute store result storage zx:work jdelay.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work jdelay.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work jdelay.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work jdelay.u3 int 1 run scoreboard players get @s manacore.u3
execute as @e[tag=zx.j_path_v,distance=0..30] at @s run function sweetdream:profession/delayed/new

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work jdelay set value {num:0.0,type:"sweetdream:skill",u0:0,u1:0,u2:0,u3:0,count:1}
data modify storage zx:work jdelay.num set from storage manacore:out r.damage
data modify storage zx:work jdelay.u0 set from storage zx:work jhit.u0
data modify storage zx:work jdelay.u1 set from storage zx:work jhit.u1
data modify storage zx:work jdelay.u2 set from storage zx:work jhit.u2
data modify storage zx:work jdelay.u3 set from storage zx:work jhit.u3
execute store result storage zx:work jdelay.count int 1 run scoreboard players get @s zx.j_im_n
scoreboard players set @s zx.j_im_n 0
execute as @e[tag=zx.victim,distance=..16,limit=1] at @s run function sweetdream:profession/delayed/new

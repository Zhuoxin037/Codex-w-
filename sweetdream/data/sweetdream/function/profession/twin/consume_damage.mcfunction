function sweetdream:lib/uuid
execute store result score #jcoef zx.meta run data get storage zx:work jt_consume.layers
scoreboard players operation #jcoef zx.meta *= #j2 zx.meta
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.02}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.max_mana_mul double .01 run scoreboard players get #jcoef zx.meta
function manacore:api/damage/calc
data modify storage zx:work a set value {target:"@e[tag=zx.j_ess_v,distance=0..4,limit=1]",type:"sweetdream:skill",u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

function sweetdream:profession/twin/locate
tag @e[tag=zx.j_path_v,distance=0..30] remove zx.j_path_v
scoreboard players set #jpath_step zx.meta 0
execute if score @s zx.j_form matches 1 if entity @e[tag=zx.j_anchor,limit=1] at @s facing entity @e[tag=zx.j_anchor,limit=1] feet run function sweetdream:profession/twin/path_ray
execute if score @s zx.j_form matches 0 if entity @e[tag=zx.j_shadow,limit=1] at @s facing entity @e[tag=zx.j_shadow,limit=1] feet run function sweetdream:profession/twin/path_ray
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.01}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
execute if score @s zx.j_il_t matches 1.. run function sweetdream:profession/twin/path_active_calc
execute if score @s zx.j_grace matches 1 run function sweetdream:profession/twin/path_echo_calc
data modify storage zx:work a set value {target:"@e[tag=zx.j_path_v,distance=0..30]",type:"sweetdream:true_damage",u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
function sweetdream:profession/twin/essence_cap
execute as @e[tag=zx.j_path_v,distance=0..30] run function sweetdream:profession/twin/essence_target
execute if score @s zx.j_il_t matches 1.. run function sweetdream:profession/twin/path_stops
tag @e[tag=zx.j_path_v,distance=0..30] remove zx.j_path_v

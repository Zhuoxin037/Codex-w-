function sweetdream:lib/uuid
execute unless entity @e[type=!#sweetdream:no_damage,distance=..5] run return 0
tag @e[tag=zx.j_cr_v,distance=0..5] remove zx.j_cr_v
tag @e[type=!#sweetdream:no_damage,distance=..5,sort=random,limit=1] add zx.j_cr_v
function sweetdream:profession/mod_begin {book_obj:"zx.j_cr_book",sor_obj:"zx.j_cr_sor"}
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.05}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.max_mana_mul double 0.01 run scoreboard players get @s zx.j_cr_d
function manacore:api/damage/calc
function sweetdream:profession/mod_end
data modify storage zx:work a set value {target:"@e[tag=zx.j_cr_v,distance=..5,limit=1]",type:"sweetdream:skill",u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
tag @e[tag=zx.j_cr_v,distance=0..5] remove zx.j_cr_v
function sweetdream:profession/mage/tally
scoreboard players operation @s zx.j_cr_d += #jorbs zx.meta

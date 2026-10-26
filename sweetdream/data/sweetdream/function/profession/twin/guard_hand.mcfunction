function sweetdream:profession/twin/unguard
summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.j_item_tmp"],Marker:1b,Invisible:1b,NoGravity:1b}
$item replace entity @e[tag=zx.j_item_tmp,limit=1] weapon.mainhand from entity @s $(hand)
execute unless data entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data" run data modify entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".j_guard_newdata set value 1b
data modify entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".j_protect set value 1b
execute if data entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:death_protection" run data modify entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".j_prior_death set from entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:death_protection"
data modify entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:death_protection" set value {death_effects:[]}
function sweetdream:lib/uuid
data modify storage zx:work jt.uuid set from storage zx:data self.uuid
$data modify storage zx:work jt.guard_key set value "$(key)"
function sweetdream:profession/twin/guard_save with storage zx:work jt
$execute if items entity @e[tag=zx.j_item_tmp,limit=1] weapon.mainhand * run item replace entity @s $(hand) from entity @e[tag=zx.j_item_tmp,limit=1] weapon.mainhand
kill @e[tag=zx.j_item_tmp]

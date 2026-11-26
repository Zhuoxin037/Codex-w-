$execute if items entity @s $(hand) *[custom_data~{j_temp:1b}] run item replace entity @s $(hand) with air
$execute unless items entity @s $(hand) * run return 0
summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.j_item_tmp"],Marker:1b,Invisible:1b,NoGravity:1b}
$item replace entity @e[tag=zx.j_item_tmp,limit=1] weapon.mainhand from entity @s $(hand)
data remove entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:death_protection"
execute if data entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".j_prior_death run data modify entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:death_protection" set from entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".j_prior_death
data remove entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".j_prior_death
scoreboard players set #jg_newdata zx.meta 0
execute store result score #jg_newdata zx.meta run data get entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".j_guard_newdata
data remove entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".j_guard_newdata
data remove entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".j_protect
scoreboard players set #jg_keys zx.meta 0
execute store result score #jg_keys zx.meta run data get entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data"
execute if score #jg_newdata zx.meta matches 1 if score #jg_keys zx.meta matches 0 run data remove entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data"

$execute if items entity @e[tag=zx.j_item_tmp,limit=1] weapon.mainhand * run item replace entity @s $(hand) from entity @e[tag=zx.j_item_tmp,limit=1] weapon.mainhand
kill @e[tag=zx.j_item_tmp]

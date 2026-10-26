execute if score @s zx.j_res_active matches 1 run return 0
scoreboard players set @s zx.j_res_active 1
scoreboard players operation @s zx.j_res_start = #now manacore.meta
function sweetdream:lib/uuid
data modify storage zx:work jr.uuid set from storage zx:data self.uuid
function sweetdream:profession/mage/resistance_save with storage zx:work jr

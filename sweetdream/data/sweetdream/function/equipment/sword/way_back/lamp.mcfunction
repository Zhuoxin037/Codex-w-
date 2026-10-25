function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work owner_arg set from storage zx:data self
function sweetdream:equipment/sword/way_back/lamp_go with storage zx:work owner_arg
scoreboard players set @s zx.wb_on 1
scoreboard players operation @s zx.wb_t = #now manacore.meta
scoreboard players add @s zx.wb_t 400
scoreboard players set @s zx.wb_dmg 0
scoreboard players set @s zx.wb_low 0
function sweetdream:equipment/sword/way_back/low_now

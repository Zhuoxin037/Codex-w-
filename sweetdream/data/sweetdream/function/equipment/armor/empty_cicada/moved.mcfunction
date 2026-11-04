execute unless entity @s[type=minecraft:player] run return 0
execute unless items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run return 0
execute unless score @s zx.s2_step_end > #now manacore.meta run return 0
data modify storage zx:work s2_move set value {id:0}
execute store result storage zx:work s2_move.id int 1 run scoreboard players get @s zx.s2_move_id
function sweetdream:equipment/armor/empty_cicada/moved_check with storage zx:work s2_move

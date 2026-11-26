scoreboard players set #safe bs.ok 0
function fallendream:boss/b_staff/move/check
execute unless score #safe bs.ok matches 1 run return 0
scoreboard players add #serial bs.id 1
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get #serial bs.id
execute summon minecraft:item_display run function fallendream:boss/b_staff/spawn/rig
execute summon minecraft:vindicator run function fallendream:boss/b_staff/spawn/body

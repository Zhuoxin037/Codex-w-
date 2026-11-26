scoreboard players add @s bs.age 1
scoreboard players operation @s bs.vframe = @s bs.age
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
function fallendream:boss/b_staff/visual/clips/death
execute if score @s bs.age matches 32.. run function fallendream:boss/b_staff/remove with storage fallendream:b_staff args
tag @s remove sd.bs.current_rig

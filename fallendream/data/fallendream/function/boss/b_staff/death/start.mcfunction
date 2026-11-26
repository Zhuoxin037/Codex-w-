execute if score @s bs.state matches 99 run return 0
scoreboard players set @s bs.state 99
scoreboard players set @s bs.age 0
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
function fallendream:boss/b_staff/cleanup_cast with storage fallendream:b_staff args
function fallendream:boss/b_staff/bar/remove with storage fallendream:b_staff args
scoreboard players set @s bs.vframe 0
function fallendream:boss/b_staff/visual/clips/death
tag @s remove sd.bs.current_rig

execute unless score @s bs.id = @s bs.id run return 0
tag @s add sd.bs.current_rig
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
execute if score @s bs.state matches 99 run return run function fallendream:boss/b_staff/death/tick
scoreboard players set #found bs.ok 0
function fallendream:boss/b_staff/rig_owner with storage fallendream:b_staff args
execute if score #found bs.ok matches 1 run scoreboard players set @s bs.wait 0
execute if score #found bs.ok matches 0 if score @s bs.wait matches 1.. run scoreboard players remove @s bs.wait 1
execute if score #found bs.ok matches 0 if score @s bs.wait matches 0 run function fallendream:boss/b_staff/death/start
tag @s remove sd.bs.current_rig

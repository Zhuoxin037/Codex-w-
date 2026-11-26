scoreboard players set @s sdh.speed 0
scoreboard players set @s sdh.walktempo 0
scoreboard players set @s sdh.state 0
scoreboard players set @s sdh.age 0
scoreboard players set @s sdh.energy 0
scoreboard players set @s sdh.flash 0
execute store result storage fallendream:husk args.id int 1 run scoreboard players get @s sdh.id
function fallendream:boss/husk/reflection/reset with storage fallendream:husk args
execute as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function fallendream_boss:husk/animations/combat_idle/play_exclusive

execute if score @s sdh.age matches 13.. unless score @s sdh.hit0 matches 1 run function sweetdream:boss/husk/hit/blast
execute if score @s sdh.age matches 23.. run scoreboard players set @s sdh.state 23
execute if score @s sdh.age matches 23.. run scoreboard players set @s sdh.age 0
execute if score @s sdh.state matches 23 as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/guard_recover/play_exclusive

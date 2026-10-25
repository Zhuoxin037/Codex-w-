execute if score @s sdh.flash matches 8 if score @s sdh.state matches 21 run function sweetdream:boss/husk/guard/react
execute if score @s sdh.flash matches 8 if score @s sdh.state matches 31 run function sweetdream:boss/husk/counter/react
execute if score @s sdh.flash matches 1.. run scoreboard players remove @s sdh.flash 1
execute if score @s sdh.flash matches 1 if score @s sdh.state matches 21 as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/guard_hold/play_exclusive
execute if score @s sdh.flash matches 1 if score @s sdh.state matches 31 as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/counter_hold/play_exclusive

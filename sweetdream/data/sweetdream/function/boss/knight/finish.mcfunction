execute if score @s sdk.state matches 8 run return run function sweetdream:boss/knight/start/stop
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function sweetdream_boss:dream_knight/transitions/clear
# Every completed attack, including ordinary attacks, leaves a real stationary opening.
scoreboard players set @s sdk.rest 30
execute if score @s sdk.state matches 5..6 run scoreboard players set @s sdk.rest 40
execute if score @s sdk.state matches 9 run scoreboard players set @s sdk.rest 40
execute if score @s sdk.state matches 11 run scoreboard players set @s sdk.rest 50
scoreboard players set @s sdk.state 0
function sweetdream:boss/knight/play_idle

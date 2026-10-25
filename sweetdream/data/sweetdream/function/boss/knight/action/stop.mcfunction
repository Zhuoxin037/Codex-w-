scoreboard players add @s sdk.age 1
execute store result storage sweetdream:knight transition.frame int 1 run scoreboard players get @s sdk.age
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function sweetdream_boss:dream_knight/transitions/stop/apply with storage sweetdream:knight transition
data remove storage sweetdream:knight transition.frame
execute if score @s sdk.age matches 6.. run function sweetdream:boss/knight/finish

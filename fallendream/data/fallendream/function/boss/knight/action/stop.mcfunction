scoreboard players add @s sdk.age 1
execute store result storage fallendream:knight transition.frame int 1 run scoreboard players get @s sdk.age
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function fallendream_boss:dream_knight/transitions/stop/apply with storage fallendream:knight transition
data remove storage fallendream:knight transition.frame
execute if score @s sdk.age matches 6.. run function fallendream:boss/knight/finish

scoreboard players add @s sdk.age 1
execute unless entity @e[tag=sd.kn.target,distance=..30,limit=1] run return run function sweetdream:boss/knight/shadow/stop
execute if score @s sdk.phase matches 1 run function sweetdream:boss/knight/shadow/protect_tick
execute if score @s sdk.age matches 49.. run return run function sweetdream:boss/knight/shadow/stop
execute store result storage sweetdream:knight cast.frame int 1 run scoreboard players get @s sdk.age
execute as @e[tag=sd.kn.current_rig,distance=..64,limit=1] run function sweetdream:boss/knight/shadow/cast/apply with storage sweetdream:knight cast
execute if score @s sdk.age matches 16 run function sweetdream:boss/knight/shadow/spawn
execute if score @s sdk.age matches 48.. run function sweetdream:boss/knight/shadow/stop

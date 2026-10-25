scoreboard players set @s sdk.state 13
scoreboard players set @s sdk.age 0
scoreboard players set @s sdk.scd 360
scoreboard players set @s sdk.lastmove 4
scoreboard players set @s sdk.protect 0
execute if score @s sdk.phase matches 1 run function sweetdream:boss/knight/shadow/protect_tick
execute if score @s sdk.phase matches 2 run function sweetdream:boss/knight/shadow/protect_phase2
execute as @e[tag=sd.kn.current_rig,distance=..64,limit=1] run function sweetdream_boss:dream_knight/animations/pause_all
data modify storage sweetdream:knight cast set value {frame:0}
execute as @e[tag=sd.kn.current_rig,distance=..64,limit=1] run function sweetdream:boss/knight/shadow/cast/apply with storage sweetdream:knight cast
playsound minecraft:block.enchantment_table.use hostile @a[distance=..32] ~ ~ ~ 0.55 0.9

scoreboard players set @s sdk.state 10
scoreboard players set @s sdk.age 0
scoreboard players set @s sdk.blocked 0
scoreboard players set @s sdk.hit0 0
scoreboard players set @s sdk.hit1 0
scoreboard players set @s sdk.hit2 0
scoreboard players set @s sdk.phase 2
data modify entity @s Invulnerable set value 1b
execute store result storage sweetdream:knight args.id int 1 run scoreboard players get @s sdk.id
function sweetdream:boss/knight/cleanup_fx with storage sweetdream:knight args
playsound minecraft:block.beacon.activate hostile @a[distance=..32] ~ ~ ~ 0.6 0.85
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function sweetdream_boss:dream_knight/animations/phase_transition/play_exclusive

execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function sweetdream_boss:dream_knight/transitions/capture_run
scoreboard players set @s sdk.state 9
scoreboard players set @s sdk.age 0
scoreboard players set @s sdk.blocked 0
scoreboard players set @s sdk.hit0 0
scoreboard players set @s sdk.hit1 0
scoreboard players set @s sdk.hit2 0
scoreboard players set @s sdk.frame 0
scoreboard players set @s sdk.tempo 0
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function sweetdream_boss:dream_knight/animations/pause_all
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function sweetdream:boss/knight/driver/apply {clip:"approach_thrust",frame:0}

# Compatibility state 8 now means hidden blink, never approach_run.
scoreboard players set @s sdk.state 8
scoreboard players set @s sdk.age 0
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function fallendream_boss:dream_knight/animations/pause_all
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function fallendream:boss/knight/blink/hide

# Reappearance starts a private 12-tick tell before the first contact.
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function fallendream_boss:dream_knight/transitions/clear
scoreboard players set @s sdk.state 9
scoreboard players set @s sdk.age 0
scoreboard players set @s sdk.blocked 0
scoreboard players set @s sdk.hit0 0
scoreboard players set @s sdk.hit1 0
scoreboard players set @s sdk.hit2 0
scoreboard players set @s sdk.frame 0
scoreboard players set @s sdk.tempo 0
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function fallendream_boss:dream_knight/animations/pause_all
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function fallendream:boss/knight/blink/apply {clip:"strike",frame:0}

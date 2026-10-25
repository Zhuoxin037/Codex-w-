scoreboard players set @s sdk.state 6
scoreboard players set @s sdk.age 0
scoreboard players set @s sdk.blocked 0
scoreboard players set @s sdk.hit0 0
scoreboard players set @s sdk.hit1 0
scoreboard players set @s sdk.hit2 0
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function sweetdream_boss:dream_knight/animations/echo_wait/play_exclusive

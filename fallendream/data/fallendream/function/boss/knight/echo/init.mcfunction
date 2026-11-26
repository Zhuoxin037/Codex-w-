tag @s add sd.kn.trace
tag @s add sd.kn.fx
scoreboard players add @e[tag=sd.kn.current_wave,distance=0..,limit=1] sdk.traces 1
scoreboard players operation @s sdk.owner = @e[tag=sd.kn.current_wave,distance=0..,limit=1] sdk.owner
scoreboard players operation @s sdk.waveid = @e[tag=sd.kn.current_wave,distance=0..,limit=1] sdk.waveid
scoreboard players set @s sdk.age 0
scoreboard players set @s sdk.active 0

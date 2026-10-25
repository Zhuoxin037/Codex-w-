tag @s remove sd.kn.new
data modify entity @s Rotation set from entity @e[tag=sd.kn.current_rig,distance=0..,limit=1] Rotation
scoreboard players set @s sdk.state 0
scoreboard players set @s sdk.age 0
scoreboard players set @s sdk.phase 1
scoreboard players set @s sdk.rest 20
scoreboard players set @s sdk.circlecd 50
scoreboard players set @s sdk.wavecd 60
scoreboard players set @s sdk.dashcd 80
scoreboard players set @s sdk.combocd 120
scoreboard players set @s sdk.lastmove 0
scoreboard players set @s sdk.fall 0
scoreboard players set @s sdk.blocked 0
scoreboard players set @s sdk.wavecount 0
scoreboard players set @s sdk.last_hp 800000

scoreboard players set @s sdk.scd 100
scoreboard players set @s sdk.protect 0

tag @s remove sd.kn.entry_walk
tag @s remove sd.kn.entry_run
scoreboard players set @s sdk.entry -1
execute if entity @s[tag=sweetdream_boss.dream_knight.animation.walk.playing] if score @s sdk.pose = @s sdk.pose run scoreboard players operation @s sdk.entry = @s sdk.pose
execute if score @s sdk.entry matches 25.. run scoreboard players set @s sdk.entry 24
execute if score @s sdk.entry matches 0..24 run tag @s add sd.kn.entry_walk

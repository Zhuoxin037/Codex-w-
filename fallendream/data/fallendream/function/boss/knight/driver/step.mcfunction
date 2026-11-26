# Executor is the collision body. Keep a private attack clock, not a previous clip's shared pose.
scoreboard players add @s sdk.frame 1
scoreboard players add @s sdk.tempo 1
execute if score @s sdk.tempo matches 4.. run scoreboard players add @s sdk.frame 1
execute if score @s sdk.tempo matches 4.. run scoreboard players set @s sdk.tempo 0

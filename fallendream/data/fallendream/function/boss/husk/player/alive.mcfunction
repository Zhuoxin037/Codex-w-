# @e excludes dead players. A health criterion can remain zero until health first changes.
scoreboard players set #alive sdh.tmp 0
tag @s add sd.hk.live_check
execute if entity @e[type=minecraft:player,tag=sd.hk.live_check,distance=0..] run scoreboard players set #alive sdh.tmp 1
tag @s remove sd.hk.live_check

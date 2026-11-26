# The owner UUID is exact; the native player/alive/world filters remain in force.
tag @s add zx.tv_owner_probe
execute if entity @e[type=minecraft:player,tag=zx.tv_owner_probe,distance=0..,limit=1] run scoreboard players set #tv_owner_alive zx.meta 1
tag @s remove zx.tv_owner_probe

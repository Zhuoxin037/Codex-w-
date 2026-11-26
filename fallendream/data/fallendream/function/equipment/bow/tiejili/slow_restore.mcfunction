effect clear @s minecraft:slowness
execute unless data storage zx:work tj_restore.original.id run return 0
execute store result score #tj_duration zx.meta run data get storage zx:work tj_restore.original.duration
execute if score #tj_duration zx.meta matches -1 run return run data modify entity @s active_effects append from storage zx:work tj_restore.original
execute store result score #tj_elapsed zx.meta run data get storage zx:work tj_restore.started
scoreboard players operation #tj_elapsed zx.meta -= #now manacore.meta
scoreboard players operation #tj_duration zx.meta += #tj_elapsed zx.meta
execute unless score #tj_duration zx.meta matches 1.. run return 0
execute store result storage zx:work tj_restore.original.duration int 1 run scoreboard players get #tj_duration zx.meta
data modify entity @s active_effects append from storage zx:work tj_restore.original

execute as @a[tag=!dh.entered] run function dreamhall:arrive
execute as @a[tag=dh.cool] at @s run function dreamhall:cool
execute as @a[gamemode=!spectator] at @s if entity @s[y=-64,dy=104] run tp @s 0.5 65 168.5 180 0

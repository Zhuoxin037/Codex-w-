# This save is a lobby building preview. No external datapack, resource pack or mod.
execute as @a[tag=!dreamlobby.entered] run function dreamlobby:arrive
execute as @a[gamemode=!spectator] at @s if entity @s[y=-64,dy=122] run tp @s 0.5 65 25.5 180 0

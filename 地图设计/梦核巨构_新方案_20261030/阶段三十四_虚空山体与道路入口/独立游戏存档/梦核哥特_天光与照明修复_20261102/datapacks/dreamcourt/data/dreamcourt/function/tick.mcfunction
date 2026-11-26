# One-time migration includes players who already entered at the old terrace.
execute as @a[tag=!dreamcourt.road_entered] run function dreamcourt:arrive
execute as @a[tag=dreamcourt.road_entered,gamemode=!spectator] at @s if entity @s[y=-1000,dy=944] run function dreamcourt:arrive

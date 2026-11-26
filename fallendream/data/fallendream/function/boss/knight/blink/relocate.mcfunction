# Choose once at disappearance's end, using the existing 30-block combat range.
tag @a[tag=sd.kn.blink_target] remove sd.kn.blink_target
execute at @s run tag @a[gamemode=!creative,gamemode=!spectator,distance=..30,sort=nearest,limit=1,nbt=!{Health:0.0f}] add sd.kn.blink_target
execute unless entity @a[tag=sd.kn.blink_target,distance=..30,limit=1] run return run function fallendream:boss/knight/finish
scoreboard players set @s sdk.clear 0
execute at @a[tag=sd.kn.blink_target,distance=0..,limit=1] facing entity @s feet rotated ~90 0 positioned ^ ^ ^2.2 run function fallendream:boss/knight/blink/try_column
execute if score @s sdk.clear matches 0 at @a[tag=sd.kn.blink_target,distance=0..,limit=1] facing entity @s feet rotated ~-90 0 positioned ^ ^ ^2.2 run function fallendream:boss/knight/blink/try_column
execute if score @s sdk.clear matches 0 at @a[tag=sd.kn.blink_target,distance=0..,limit=1] facing entity @s feet rotated ~0 0 positioned ^ ^ ^2.2 run function fallendream:boss/knight/blink/try_column
execute if score @s sdk.clear matches 0 at @a[tag=sd.kn.blink_target,distance=0..,limit=1] facing entity @s feet rotated ~180 0 positioned ^ ^ ^2.2 run function fallendream:boss/knight/blink/try_column
execute if score @s sdk.clear matches 0 at @a[tag=sd.kn.blink_target,distance=0..,limit=1] facing entity @s feet rotated ~45 0 positioned ^ ^ ^2.2 run function fallendream:boss/knight/blink/try_column
execute if score @s sdk.clear matches 0 at @a[tag=sd.kn.blink_target,distance=0..,limit=1] facing entity @s feet rotated ~-45 0 positioned ^ ^ ^2.2 run function fallendream:boss/knight/blink/try_column
execute if score @s sdk.clear matches 0 at @a[tag=sd.kn.blink_target,distance=0..,limit=1] facing entity @s feet rotated ~135 0 positioned ^ ^ ^2.2 run function fallendream:boss/knight/blink/try_column
execute if score @s sdk.clear matches 0 at @a[tag=sd.kn.blink_target,distance=0..,limit=1] facing entity @s feet rotated ~-135 0 positioned ^ ^ ^2.2 run function fallendream:boss/knight/blink/try_column
tag @a[tag=sd.kn.blink_target] remove sd.kn.blink_target
execute if score @s sdk.clear matches 0 run function fallendream:boss/knight/finish

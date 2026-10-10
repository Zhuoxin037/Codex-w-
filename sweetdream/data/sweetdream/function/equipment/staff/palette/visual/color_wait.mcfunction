# Owner lookup was done by color_tick. Stay at the owner's eyes until release.
execute unless entity @a[tag=zx.mc_by,distance=0..,limit=1] run return run function sweetdream:equipment/staff/palette/color_end
execute at @a[tag=zx.mc_by,distance=0..,limit=1] anchored eyes positioned ^ ^ ^1.5 run tp @s ~ ~ ~ ~ ~
scoreboard players remove @s zx.pv_wait 1
execute if score @s zx.pv_wait matches 0 run function sweetdream:equipment/staff/palette/visual/color_launch

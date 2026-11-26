data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=1}] unless entity @a[tag=zx.ub,scores={zx.job=4}] run return run function fallendream:profession/delayed/finish
execute unless entity @s run return 0
scoreboard players remove @s zx.j_pulse 1
execute unless score @s zx.j_pulse matches ..0 run return 0
function fallendream:profession/delayed/hit with entity @s data
scoreboard players remove @s zx.j_life 1
scoreboard players set @s zx.j_pulse 10
execute if score @s zx.j_life matches ..0 run return run function fallendream:profession/delayed/finish

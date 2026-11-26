execute unless entity @s[tag=zx.burial_core] run return 0
scoreboard players set #burial_found zx.meta 1
tag @s remove zx.burial_core
data modify storage zx:work burial_snapshot set from entity @s data
execute store result storage zx:work burial_snapshot.num double .001 run scoreboard players get @s zx.burial_val
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
tag @e[tag=zx.burial_landed,distance=0..] remove zx.burial_landed
execute as @a[tag=zx.ub,scores={zx.job=1},distance=0..,limit=1] positioned ~ ~ ~ run function fallendream:equipment/staff/star_burial/explosion_damage
execute as @e[tag=zx.burial_landed,distance=0..] at @s run function fallendream:equipment/staff/star_burial/delay_new
tag @e[tag=zx.burial_landed,distance=0..] remove zx.burial_landed
kill @s

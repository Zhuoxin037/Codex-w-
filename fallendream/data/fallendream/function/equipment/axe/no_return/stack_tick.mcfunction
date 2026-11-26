execute if score @s zx.nr_due > #now manacore.meta run return 0
scoreboard players operation #nr_expired zx.meta = @s zx.nr_val
scoreboard players operation #nr_gen zx.meta = @s zx.nr_gen
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] if score @s zx.nr_gen = #nr_gen zx.meta run scoreboard players operation @s zx.nr_extra -= #nr_expired zx.meta
execute as @a[tag=zx.ub,limit=1] if score @s zx.nr_gen = #nr_gen zx.meta if score @s zx.nr_extra matches ..0 run scoreboard players set @s zx.nr_extra 0
execute as @a[tag=zx.ub,limit=1] if score @s zx.nr_gen = #nr_gen zx.meta if score #nr_expired zx.meta matches 1.. run scoreboard players set @s zx.s2_natural 1
kill @s

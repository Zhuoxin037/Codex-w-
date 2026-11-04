data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
scoreboard players set #phase_enh zx.meta 0
execute as @a[tag=zx.ub,scores={zx.job=4},distance=0..,limit=1] if score @s zx.wp_until > #now manacore.meta run scoreboard players set #phase_enh zx.meta 1
execute unless entity @a[tag=zx.ub,scores={zx.job=4},distance=0..,limit=1] run return 0
scoreboard players set @s zx.wp_red 0
scoreboard players set @s zx.wp_white 0
scoreboard players operation @s zx.wp_gate = #now manacore.meta
execute if score #phase_enh zx.meta matches 0 run scoreboard players add @s zx.wp_gate 40
execute if score #phase_enh zx.meta matches 1 run scoreboard players add @s zx.wp_gate 20
data modify storage zx:work phase4 set from entity @s data
execute as @a[tag=zx.ub,scores={zx.job=4},distance=0..,limit=1] positioned ~ ~ ~ run function sweetdream:equipment/staff/world_parting/pending_new

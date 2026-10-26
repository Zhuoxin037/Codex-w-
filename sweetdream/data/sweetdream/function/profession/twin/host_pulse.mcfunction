data modify storage zx:work ub set from entity @s data.jhost
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=4,zx.j_form=0,zx.j_host_t=1..}] run tag @s remove zx.j_host
execute unless entity @s[tag=zx.j_host] run return 0
scoreboard players set #jero_pct zx.meta 60
execute if entity @a[tag=zx.ub,scores={zx.j_aw=1}] run scoreboard players set #jero_pct zx.meta 70
effect give @e[type=!#sweetdream:no_damage,distance=..5] minecraft:slowness 2 1 true
execute as @e[type=!#sweetdream:no_damage,distance=..5] run function sweetdream:profession/twin/erode

scoreboard players set #jhostray zx.meta 0
tag @e[tag=zx.j_host_pick,distance=0..16] remove zx.j_host_pick
execute anchored eyes positioned ^ ^ ^.25 run function sweetdream:profession/twin/host_ray
execute unless entity @e[tag=zx.j_host_pick,limit=1] run tellraw @s {"text":"准星未命中 12 格内具有「本质」的生物。","color":"red"}
execute unless entity @e[tag=zx.j_host_pick,limit=1] run return fail
scoreboard players set @s zx.j_pick 0
function sweetdream:profession/twin/record
function sweetdream:profession/twin/host_install with storage zx:work jt
tag @e[tag=zx.j_host_pick,distance=0..16] remove zx.j_host_pick

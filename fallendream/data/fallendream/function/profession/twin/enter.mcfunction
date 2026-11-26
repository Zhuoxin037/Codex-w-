execute if score @s zx.j_host_t matches 1.. run function fallendream:profession/twin/cancel_host
function fallendream:profession/twin/record
function fallendream:profession/twin/snapshot_body with storage zx:work jt
function fallendream:profession/twin/chunk_prepare
function fallendream:profession/twin/locate
summon minecraft:villager ~ ~ ~ {Tags:["zx.j_body","zx.j_anchor","zx.j_new"],NoAI:1b,Invulnerable:1b,Silent:1b,PersistenceRequired:1b,Pose:"SLEEPING",CustomName:{text:"沉睡的本我者",color:"aqua"},CustomNameVisible:1b,attributes:[{id:"minecraft:max_health",base:16.0}]}
function fallendream:profession/twin/init_body with storage zx:work jt
effect give @e[tag=zx.j_new,limit=1] minecraft:resistance infinite 1 true
execute if score @s zx.j_aw matches 1 run effect give @e[tag=zx.j_new,limit=1] minecraft:resistance infinite 2 true
execute if score @s zx.j_aw matches 1 run effect give @e[tag=zx.j_new,limit=1] minecraft:regeneration infinite 1 true
execute as @e[tag=zx.j_new,limit=1] run function fallendream:profession/twin/protect_proxy
tag @e[tag=zx.j_new] remove zx.j_new
scoreboard players set @s zx.j_form 1
tag @s add zx.j_twin_live
function fallendream:profession/stats
function fallendream:profession/twin/restore_twin with storage zx:work jt
execute as @e[tag=zx.j_shadow,distance=0..] run function fallendream:profession/twin/despawn
scoreboard players operation @s zx.j_hpnow = @s zx.hp_c

function fallendream:profession/twin/guard

execute if score @s zx.j_host_t matches 1.. run function sweetdream:profession/twin/cancel_host
function sweetdream:profession/twin/record
function sweetdream:profession/twin/snapshot_body with storage zx:work jt
function sweetdream:profession/twin/chunk_prepare
function sweetdream:profession/twin/locate
summon minecraft:villager ~ ~ ~ {Tags:["zx.j_body","zx.j_anchor","zx.j_new"],NoAI:1b,PersistenceRequired:1b,Silent:1b,Pose:"SLEEPING",CustomName:{text:"沉睡的本我者",color:"aqua"},CustomNameVisible:1b,attributes:[{id:"minecraft:max_health",base:16.0}]}
function sweetdream:profession/twin/init_body with storage zx:work jt
effect give @e[tag=zx.j_new,limit=1] minecraft:resistance infinite 1 true
execute if score @s zx.j_aw matches 1 run effect give @e[tag=zx.j_new,limit=1] minecraft:resistance infinite 2 true
execute if score @s zx.j_aw matches 1 run effect give @e[tag=zx.j_new,limit=1] minecraft:regeneration infinite 1 true
tag @e[tag=zx.j_new] remove zx.j_new
scoreboard players set @s zx.j_form 1
tag @s add zx.j_twin_live
function sweetdream:profession/stats
function sweetdream:profession/twin/restore_twin with storage zx:work jt
kill @e[tag=zx.j_shadow,distance=0..]
scoreboard players operation @s zx.j_hpnow = @s zx.hp_c

function sweetdream:profession/twin/guard

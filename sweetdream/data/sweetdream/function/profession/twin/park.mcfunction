summon minecraft:allay ~ ~ ~ {Tags:["zx.j_twin","zx.j_new"],NoAI:1b,Invulnerable:1b,Silent:1b,NoGravity:1b,PersistenceRequired:1b,CustomName:{text:"同生体",color:"light_purple"},Health:5.0f,attributes:[{id:"minecraft:max_health",base:5.0}]}
function sweetdream:profession/twin/init_park with storage zx:work jt
execute as @e[tag=zx.j_new,limit=1] run function sweetdream:profession/twin/protect_proxy
tag @e[tag=zx.j_new] remove zx.j_new

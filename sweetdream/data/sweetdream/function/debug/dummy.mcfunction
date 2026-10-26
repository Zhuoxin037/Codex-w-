tag @e[tag=zx.debug_dummy_new,distance=0..] remove zx.debug_dummy_new
execute at @s rotated ~ 0 positioned ^ ^ ^3 run summon minecraft:villager ~ ~ ~ {Tags:["zx.debug_dummy","zx.debug_dummy_new"],Health:1024f,attributes:[{id:"minecraft:max_health",base:1024d}],NoAI:1b,Silent:1b,PersistenceRequired:1b,CustomName:{text:"测试村民 · 1024血",color:"green"},CustomNameVisible:1b}
execute as @e[tag=zx.debug_dummy_new,distance=0..,limit=1] run function sweetdream:debug/dummy_init
tag @e[tag=zx.debug_dummy_new,distance=0..] remove zx.debug_dummy_new
tellraw @s {text:"[调试] 已召唤1024血测试村民。",color:"green"}

scoreboard objectives add sdbf.id dummy
scoreboard objectives add sdbf.state dummy
scoreboard objectives add sdbf.rest dummy
scoreboard objectives add sdbf.dashcd dummy
scoreboard objectives add sdbf.jumpcd dummy
scoreboard objectives add sdbf.shortcd dummy
scoreboard objectives add sdbf.age dummy
scoreboard objectives add sdbf.moved dummy
scoreboard objectives add sdbf.step dummy
scoreboard objectives add sdbf.hp dummy
scoreboard objectives add sdbf.frame dummy
scoreboard objectives add sdbf.blocked dummy
scoreboard objectives add sdbf.choice dummy
scoreboard players set #ground_0 sdbf.step 0
scoreboard players set #ground_1 sdbf.step 1
scoreboard players set #ray_6 sdbf.step 6
scoreboard players set #ray_8 sdbf.step 8
scoreboard players set #ray_10 sdbf.step 10
execute unless data storage sweetdream:fireaxe bars run data modify storage sweetdream:fireaxe bars set value []
scoreboard players set #bars sdbf.step 0
scoreboard objectives add sdbf.hp1000 dummy
scoreboard objectives add sdbf.last_hp dummy
scoreboard objectives add sdbf.death_age dummy
scoreboard objectives add sdbf.so0 dummy
scoreboard objectives add sdbf.so1 dummy
scoreboard objectives add sdbf.so2 dummy
scoreboard objectives add sdbf.so3 dummy
execute in minecraft:overworld as @e[tag=sd.fb.body,distance=0..] run function sweetdream:boss/fireaxe/reconfigure
execute in minecraft:the_nether as @e[tag=sd.fb.body,distance=0..] run function sweetdream:boss/fireaxe/reconfigure
execute in minecraft:the_end as @e[tag=sd.fb.body,distance=0..] run function sweetdream:boss/fireaxe/reconfigure
execute in minecraft:overworld as @e[tag=sd.fb.rig,distance=0..] run function sweetdream:boss/fireaxe/visual/light
execute in minecraft:the_nether as @e[tag=sd.fb.rig,distance=0..] run function sweetdream:boss/fireaxe/visual/light
execute in minecraft:the_end as @e[tag=sd.fb.rig,distance=0..] run function sweetdream:boss/fireaxe/visual/light
scoreboard objectives add sdbf.dphase dummy
scoreboard objectives add sdbf.fall dummy
scoreboard objectives add sdbf.fallsteps dummy
scoreboard objectives add sdbf.phase dummy
scoreboard objectives add sdbf.jstep dummy
scoreboard objectives add sdbf.cmask dummy

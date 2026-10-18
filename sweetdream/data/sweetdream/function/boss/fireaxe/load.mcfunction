scoreboard objectives add sdbf.num dummy
scoreboard objectives add sdbf.dtime dummy
scoreboard objectives add sdbf.dspeed dummy
scoreboard objectives add sdbf.sprint dummy
scoreboard objectives add sdbf.ltotal dummy
scoreboard objectives add sdbf.lbudget dummy
scoreboard objectives add sdbf.lticks dummy
scoreboard objectives add sdbf.lmove dummy
scoreboard objectives add sdbf.oldhp dummy
scoreboard objectives add sdbf.pendhp dummy
scoreboard objectives add sdbf.nexthp dummy
scoreboard objectives add sdbf.dmg dummy
scoreboard objectives add sdbf.extra dummy
scoreboard objectives add sdbf.dmgok dummy
scoreboard objectives add sdbf.maxhp dummy
scoreboard objectives add sdbf.armorphase dummy
scoreboard objectives add sdbf.fxland dummy
scoreboard objectives add sdbf.fxsteps dummy
scoreboard players set #5 sdbf.num 5
scoreboard players set #10 sdbf.num 10
scoreboard players set #300 sdbf.num 300
scoreboard players set #1000 sdbf.num 1000
scoreboard players set #250000 sdbf.num 250000
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
scoreboard objectives add sdbf.last_combo dummy
scoreboard objectives add sdbf.jclear dummy
scoreboard objectives add sdbf.fxage dummy
execute in minecraft:overworld run kill @e[tag=sd.fb.fx,distance=0..]
execute in minecraft:the_nether run kill @e[tag=sd.fb.fx,distance=0..]
execute in minecraft:the_end run kill @e[tag=sd.fb.fx,distance=0..]
execute in minecraft:overworld as @e[tag=sd.fb.body,distance=0..] run function sweetdream:boss/fireaxe/mechanics/init
execute in minecraft:the_nether as @e[tag=sd.fb.body,distance=0..] run function sweetdream:boss/fireaxe/mechanics/init
execute in minecraft:the_end as @e[tag=sd.fb.body,distance=0..] run function sweetdream:boss/fireaxe/mechanics/init

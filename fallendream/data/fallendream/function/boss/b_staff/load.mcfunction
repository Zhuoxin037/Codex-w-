scoreboard objectives add bs.id dummy
scoreboard objectives add bs.state dummy
scoreboard objectives add bs.age dummy
scoreboard objectives add bs.vclip dummy
scoreboard objectives add bs.vframe dummy
scoreboard objectives add bs.oldclip dummy
scoreboard objectives add bs.oldframe dummy
scoreboard objectives add bs.hp dummy
scoreboard objectives add bs.lastHP dummy
scoreboard objectives add bs.clock dummy
scoreboard objectives add bs.rest dummy
scoreboard objectives add bs.near dummy
scoreboard objectives add bs.turn dummy
scoreboard objectives add bs.last dummy
scoreboard objectives add bs.choice dummy
scoreboard objectives add bs.cd dummy
scoreboard objectives add bs.moved dummy
scoreboard objectives add bs.dir dummy
scoreboard objectives add bs.path dummy
scoreboard objectives add bs.shock dummy
scoreboard objectives add bs.owner dummy
scoreboard objectives add bs.cast dummy
scoreboard objectives add bs.life dummy
scoreboard objectives add bs.fage dummy
scoreboard objectives add bs.born dummy
scoreboard objectives add bs.kind dummy
scoreboard objectives add bs.dmg dummy
scoreboard objectives add bs.limit dummy
scoreboard objectives add bs.interval dummy
scoreboard objectives add bs.hits dummy
scoreboard objectives add bs.next dummy
scoreboard objectives add bs.ok dummy
scoreboard objectives add bs.freeze dummy
scoreboard objectives add bs.yaw dummy
scoreboard objectives add bs.oldyaw dummy
scoreboard objectives add bs.bar dummy
scoreboard objectives add bs.ray dummy
scoreboard objectives add bs.cfg dummy
scoreboard objectives add bs.x dummy
scoreboard objectives add bs.z dummy
scoreboard objectives add bs.dx dummy
scoreboard objectives add bs.dz dummy
scoreboard objectives add bs.r2 dummy
scoreboard objectives add bs.reacted dummy
scoreboard objectives add bs.wait dummy
execute unless score #serial bs.id = #serial bs.id run scoreboard players set #serial bs.id 0
execute unless score #serial bs.cast = #serial bs.cast run scoreboard players set #serial bs.cast 0
scoreboard players set #100 bs.cfg 100
scoreboard players set #four bs.cfg 4
scoreboard players set #cast_three bs.cfg 4
scoreboard players set #fan_volley bs.cfg 5
scoreboard players set #mark_ground bs.cfg 6
scoreboard players set #ring_wave bs.cfg 5
scoreboard players set #repel_retreat bs.cfg 4
scoreboard players set #scatter_cross bs.cfg 5
execute in minecraft:overworld as @e[tag=sd.bs.body,distance=0..] at @s run function fallendream:boss/b_staff/reload
execute in minecraft:overworld run kill @e[tag=sd.bs.fx,distance=0..]
execute in minecraft:the_nether as @e[tag=sd.bs.body,distance=0..] at @s run function fallendream:boss/b_staff/reload
execute in minecraft:the_nether run kill @e[tag=sd.bs.fx,distance=0..]
execute in minecraft:the_end as @e[tag=sd.bs.body,distance=0..] at @s run function fallendream:boss/b_staff/reload
execute in minecraft:the_end run kill @e[tag=sd.bs.fx,distance=0..]
execute in fallendream:rogue_preview as @e[tag=sd.bs.body,distance=0..] at @s run function fallendream:boss/b_staff/reload
execute in fallendream:rogue_preview run kill @e[tag=sd.bs.fx,distance=0..]

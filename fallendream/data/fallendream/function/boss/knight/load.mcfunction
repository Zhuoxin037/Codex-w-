scoreboard objectives add sdk.id dummy
scoreboard objectives add sdk.state dummy
scoreboard objectives add sdk.age dummy
scoreboard objectives add sdk.hp dummy
scoreboard objectives add sdk.hp1000 dummy
scoreboard objectives add sdk.last_hp dummy
scoreboard objectives add sdk.phase dummy
scoreboard objectives add sdk.frame dummy
scoreboard objectives add sdk.rest dummy
scoreboard objectives add sdk.circlecd dummy
scoreboard objectives add sdk.wavecd dummy
scoreboard objectives add sdk.dashcd dummy
scoreboard objectives add sdk.combocd dummy
scoreboard objectives add sdk.choice dummy
scoreboard objectives add sdk.lastmove dummy
scoreboard objectives add sdk.moved dummy
scoreboard objectives add sdk.fall dummy
scoreboard objectives add sdk.fallsteps dummy
scoreboard objectives add sdk.blocked dummy
scoreboard objectives add sdk.hit0 dummy
scoreboard objectives add sdk.hit1 dummy
scoreboard objectives add sdk.hit2 dummy
scoreboard objectives add sdk.wavecount dummy
scoreboard objectives add sdk.waveid dummy
scoreboard objectives add sdk.owner dummy
scoreboard objectives add sdk.echo dummy
scoreboard objectives add sdk.active dummy
scoreboard objectives add sdk.lastwave dummy
scoreboard objectives add sdk.lastecho dummy
scoreboard objectives add sdk.serial dummy
scoreboard objectives add sdk.death dummy
scoreboard objectives add sdk.ray dummy
scoreboard objectives add sdk.clear dummy
scoreboard objectives add sdk.step dummy
scoreboard objectives add sdk.speed dummy
scoreboard objectives add sdk.traces dummy
execute unless score #wave sdk.serial = #wave sdk.serial run scoreboard players set #wave sdk.serial 0
scoreboard players set #bars sdk.step 0
scoreboard players set #two sdk.step 2
scoreboard objectives add sdk.tempo dummy
scoreboard objectives add sdk.entry dummy
scoreboard objectives add sdk.pose dummy

scoreboard objectives add sdk.scd dummy
scoreboard objectives add sdk.protect dummy
scoreboard objectives add sdk.inv dummy
scoreboard objectives add sdk.resamp dummy
scoreboard objectives add sdk.spawned dummy
scoreboard objectives add sdk.quota dummy
execute unless score #shadow sdk.serial = #shadow sdk.serial run scoreboard players set #shadow sdk.serial 0
execute in minecraft:overworld as @e[tag=sd.kn.shadow,distance=0..] at @s run function fallendream:boss/knight/shadow/end
execute in minecraft:overworld run kill @e[tag=sd.kn.shadow_bone,distance=0..]
execute in minecraft:overworld as @e[tag=sd.kn.body,scores={sdk.state=13},distance=0..] at @s run function fallendream:boss/knight/shadow/reload_cancel
execute in minecraft:the_nether as @e[tag=sd.kn.shadow,distance=0..] at @s run function fallendream:boss/knight/shadow/end
execute in minecraft:the_nether run kill @e[tag=sd.kn.shadow_bone,distance=0..]
execute in minecraft:the_nether as @e[tag=sd.kn.body,scores={sdk.state=13},distance=0..] at @s run function fallendream:boss/knight/shadow/reload_cancel
execute in minecraft:the_end as @e[tag=sd.kn.shadow,distance=0..] at @s run function fallendream:boss/knight/shadow/end
execute in minecraft:the_end run kill @e[tag=sd.kn.shadow_bone,distance=0..]
execute in minecraft:the_end as @e[tag=sd.kn.body,scores={sdk.state=13},distance=0..] at @s run function fallendream:boss/knight/shadow/reload_cancel

# Blink visibility is reversible on reload, including orphaned bone displays.
scoreboard objectives add sdk.bview dummy
execute in minecraft:overworld as @e[tag=sd.kn.rig,tag=sd.kn.blink_hidden,distance=0..] run function fallendream:boss/knight/blink/show
execute in minecraft:the_nether as @e[tag=sd.kn.rig,tag=sd.kn.blink_hidden,distance=0..] run function fallendream:boss/knight/blink/show
execute in minecraft:the_end as @e[tag=sd.kn.rig,tag=sd.kn.blink_hidden,distance=0..] run function fallendream:boss/knight/blink/show
execute in minecraft:overworld as @e[tag=sd.kn.blink_bone,distance=0..] run function fallendream:boss/knight/blink/show_bone
execute in minecraft:overworld as @e[tag=sd.kn.body,scores={sdk.state=7..9},distance=0..] at @s run function fallendream:boss/knight/blink/reload_cancel
execute in minecraft:the_nether as @e[tag=sd.kn.blink_bone,distance=0..] run function fallendream:boss/knight/blink/show_bone
execute in minecraft:the_nether as @e[tag=sd.kn.body,scores={sdk.state=7..9},distance=0..] at @s run function fallendream:boss/knight/blink/reload_cancel
execute in minecraft:the_end as @e[tag=sd.kn.blink_bone,distance=0..] run function fallendream:boss/knight/blink/show_bone
execute in minecraft:the_end as @e[tag=sd.kn.body,scores={sdk.state=7..9},distance=0..] at @s run function fallendream:boss/knight/blink/reload_cancel

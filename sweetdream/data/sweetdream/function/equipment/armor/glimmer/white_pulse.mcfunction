execute if score @s zx.gl_cd > #now manacore.meta run return 0
scoreboard players operation @s zx.gl_cd = #now manacore.meta
scoreboard players operation @s zx.gl_cd += #60 manacore.meta
execute at @s run tag @e[type=!#sweetdream:no_damage, type=!minecraft:player, distance=..5, sort=random, limit=4] add zx.gl_p4
execute store result storage zx:work gl_owner.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work gl_owner.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work gl_owner.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work gl_owner.u3 int 1 run scoreboard players get @s manacore.u3
execute as @e[tag=zx.gl_p4, distance=0..] at @s run function sweetdream:equipment/armor/glimmer/white_one with storage zx:work gl_owner
execute at @s run particle minecraft:dust{color:[1.0,1.0,1.0],scale:2.0} ~ ~1.2 ~ 3.0 4.0 3.0 0.05 40
execute at @s run playsound minecraft:block.beacon.activate player @s ~ ~ ~ 0.5 1.8
tag @e[tag=zx.gl_p4, distance=0..] remove zx.gl_p4

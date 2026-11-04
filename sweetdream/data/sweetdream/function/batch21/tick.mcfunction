execute as @a at @s run function sweetdream:batch21/player_tick
execute in minecraft:overworld as @e[tag=zx.s2_cicada,distance=0..] at @s run function sweetdream:equipment/armor/empty_cicada/shadow_tick
execute in minecraft:the_nether as @e[tag=zx.s2_cicada,distance=0..] at @s run function sweetdream:equipment/armor/empty_cicada/shadow_tick
execute in minecraft:the_end as @e[tag=zx.s2_cicada,distance=0..] at @s run function sweetdream:equipment/armor/empty_cicada/shadow_tick
execute in minecraft:overworld as @e[tag=zx.s2_move_start,distance=0..] unless score @s zx.s2_end > #now manacore.meta run kill @s
execute in minecraft:the_nether as @e[tag=zx.s2_move_start,distance=0..] unless score @s zx.s2_end > #now manacore.meta run kill @s
execute in minecraft:the_end as @e[tag=zx.s2_move_start,distance=0..] unless score @s zx.s2_end > #now manacore.meta run kill @s

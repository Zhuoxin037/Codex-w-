execute as @a at @s run function sweetdream:profession/player_tick
execute in minecraft:overworld as @e[tag=zx.j_follower,distance=0..] at @s run function sweetdream:profession/singer/follower_tick
execute in minecraft:overworld as @e[tag=zx.j_body,distance=0..] at @s run function sweetdream:profession/twin/body_tick
execute in minecraft:overworld as @e[tag=zx.j_choice,distance=0..] run function sweetdream:profession/choice_tick
execute in minecraft:overworld as @e[tag=zx.j_eroded,distance=0..] run function sweetdream:profession/twin/erode_tick
execute in minecraft:the_nether as @e[tag=zx.j_follower,distance=0..] at @s run function sweetdream:profession/singer/follower_tick
execute in minecraft:the_nether as @e[tag=zx.j_body,distance=0..] at @s run function sweetdream:profession/twin/body_tick
execute in minecraft:the_nether as @e[tag=zx.j_choice,distance=0..] run function sweetdream:profession/choice_tick
execute in minecraft:the_nether as @e[tag=zx.j_eroded,distance=0..] run function sweetdream:profession/twin/erode_tick
execute in minecraft:the_end as @e[tag=zx.j_follower,distance=0..] at @s run function sweetdream:profession/singer/follower_tick
execute in minecraft:the_end as @e[tag=zx.j_body,distance=0..] at @s run function sweetdream:profession/twin/body_tick
execute in minecraft:the_end as @e[tag=zx.j_choice,distance=0..] run function sweetdream:profession/choice_tick
execute in minecraft:the_end as @e[tag=zx.j_eroded,distance=0..] run function sweetdream:profession/twin/erode_tick

execute in minecraft:overworld as @e[tag=zx.j_delayed,distance=0..] at @s run function sweetdream:profession/delayed/tick
execute in minecraft:the_nether as @e[tag=zx.j_delayed,distance=0..] at @s run function sweetdream:profession/delayed/tick
execute in minecraft:the_end as @e[tag=zx.j_delayed,distance=0..] at @s run function sweetdream:profession/delayed/tick

execute in minecraft:overworld as @e[tag=zx.j_host_watch,distance=0..] at @s run function sweetdream:profession/twin/host_watch_tick
execute in minecraft:the_nether as @e[tag=zx.j_host_watch,distance=0..] at @s run function sweetdream:profession/twin/host_watch_tick
execute in minecraft:the_end as @e[tag=zx.j_host_watch,distance=0..] at @s run function sweetdream:profession/twin/host_watch_tick

execute in minecraft:overworld as @e[tag=zx.j_taunt_reset,distance=0..] run function sweetdream:profession/twin/taunt_reset_tick
execute in minecraft:the_nether as @e[tag=zx.j_taunt_reset,distance=0..] run function sweetdream:profession/twin/taunt_reset_tick
execute in minecraft:the_end as @e[tag=zx.j_taunt_reset,distance=0..] run function sweetdream:profession/twin/taunt_reset_tick

execute in minecraft:overworld as @e[tag=zx.j_guard_carrier,distance=0..] run function sweetdream:profession/twin/guard_carrier_tick
execute in minecraft:the_nether as @e[tag=zx.j_guard_carrier,distance=0..] run function sweetdream:profession/twin/guard_carrier_tick
execute in minecraft:the_end as @e[tag=zx.j_guard_carrier,distance=0..] run function sweetdream:profession/twin/guard_carrier_tick

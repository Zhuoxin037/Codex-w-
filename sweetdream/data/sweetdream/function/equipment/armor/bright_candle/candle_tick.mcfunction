# This function now runs each tick. The last completed second is paid at the deadline.
execute unless score @s zx.bc_end matches 1.. run return run kill @s
scoreboard players operation #bc_start zx.meta = @s zx.bc_end
scoreboard players remove #bc_start zx.meta 200
execute if score #bc_start zx.meta >= #now manacore.meta run return 0
execute if score @s zx.bc_end < #now manacore.meta run return run kill @s
tag @s add zx.bc_current
execute store result storage zx:work bc_clock.cid int 1 run scoreboard players get @s zx.bc_id
execute store result storage zx:work bc_clock.end int 1 run scoreboard players get @s zx.bc_end
execute at @s as @e[type=!#sweetdream:no_damage,tag=zx.status.liuhuo,distance=..5] run function sweetdream:equipment/armor/bright_candle/dwell with storage zx:work bc_clock
tag @s remove zx.bc_current
execute if score @s zx.bc_next <= #now manacore.meta run function sweetdream:equipment/armor/bright_candle/candle_second
scoreboard players remove @s zx.bc_fx 1
execute if score @s zx.bc_fx matches ..0 run particle minecraft:small_flame ~ ~0.5 ~ 0.06 0.1 0.06 0.01 4 normal
execute if score @s zx.bc_fx matches ..0 run particle minecraft:smoke ~ ~0.55 ~ 0.04 0.04 0.04 0.005 1 normal
execute if score @s zx.bc_fx matches ..0 run scoreboard players set @s zx.bc_fx 5
execute if score @s zx.bc_end <= #now manacore.meta run kill @s

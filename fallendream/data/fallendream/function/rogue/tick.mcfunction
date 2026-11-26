execute if score #rv_clean zx.meta matches 1.. run function fallendream:rogue/cleanup/tick
execute if score #rv_clean zx.meta matches 0 if score #rd_phase zx.meta matches 0 unless data storage zx:rogue {built:1b} if entity @a[tag=zx.rg_wait] run function fallendream:rogue/gen/request
execute if score #rd_phase zx.meta matches 1.. run function fallendream:rogue/gen/tick
execute if data storage zx:rogue {built:1b} as @a[tag=zx.rg_wait] at @s run function fallendream:rogue/prep/begin
execute as @a[tag=zx.rg_prep] at @s run function fallendream:rogue/prep/tick
execute as @a[tag=zx.rg_active] at @s run function fallendream:rogue/player_tick
scoreboard players add #rg_clock zx.meta 1
execute if score #rg_clock zx.meta matches 20.. run function fallendream:rogue/second
execute if score #rg_clock zx.meta matches 20.. run scoreboard players set #rg_clock zx.meta 0

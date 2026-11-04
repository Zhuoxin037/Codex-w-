execute unless score #rv_clean zx.meta matches 0.. run scoreboard players set #rv_clean zx.meta 0
execute unless score #rd_forced zx.meta matches 0.. run scoreboard players set #rd_forced zx.meta 0
execute unless score #rd_phase zx.meta matches 0.. run scoreboard players set #rd_phase zx.meta 0
execute unless data storage zx:rogue {version:3} as @a[tag=zx.rg_prep] at @s run function sweetdream:rogue/prototype/exit
execute unless data storage zx:rogue {version:3} as @a[tag=zx.rg_active] at @s run function sweetdream:rogue/prototype/exit
execute unless data storage zx:rogue {version:3} as @a[tag=zx.rg_wait] at @s run function sweetdream:rogue/prototype/exit
execute unless data storage zx:rogue {version:3} run function sweetdream:rogue/cleanup/request
data modify storage zx:rogue version set value 3
execute unless score #rd_serial zx.meta matches 0.. run scoreboard players set #rd_serial zx.meta 0
execute unless score #rd_rev zx.meta matches 0.. run scoreboard players set #rd_rev zx.meta 0
scoreboard players set #rg_clock zx.meta 0

fill -16 319 -16 111 319 111 minecraft:air
kill @e[tag=zx.rg_tmp,distance=0..]
execute as @e[type=minecraft:item,distance=0..] if data entity @s Item.components."minecraft:custom_data"{rg_map:1b} run kill @s
data remove storage zx:rogue floor
data modify storage zx:rogue built set value 0b
scoreboard players set #rv_clean zx.meta 0
scoreboard players set #rd_forced zx.meta 0
forceload remove -16 -16 144 144

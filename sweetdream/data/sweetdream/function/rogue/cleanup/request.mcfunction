execute if score #rv_clean zx.meta matches 1.. run return 0
data modify storage zx:rogue built set value 0b
scoreboard players set #rd_phase zx.meta 0
scoreboard players set #rv_clean zx.meta 1
scoreboard players set #rv_clean_wait zx.meta 0
scoreboard players set #rv_clean_i zx.meta 0
execute in sweetdream:rogue_preview run forceload add -16 -16 144 144
scoreboard players set #rd_forced zx.meta 1

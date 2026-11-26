# The old Overworld run ends cleanly at the lobby. The new layout initializes on entry.
execute if score #rd_forced zx.meta matches 1 in minecraft:overworld run forceload remove -16 -16 144 144
execute if score #rd_forced zx.meta matches 1 in minecraft:overworld run forceload add 0 0
scoreboard players set #phase sd.floor 0
scoreboard players set #rd_forced zx.meta 0
scoreboard players set #rd_phase zx.meta 0
scoreboard players set #rv_clean zx.meta 0
data modify storage zx:rogue built set value 0b
data remove storage zx:rogue floor
data remove storage sweetdream_floor:run forest_biome
data remove storage sweetdream_floor:run encounter
data modify storage sweetdream_floor:run dimension_layout set value 1b

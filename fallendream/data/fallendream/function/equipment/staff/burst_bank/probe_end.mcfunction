# marker记录预检落点后由start复原到施放起点。
execute store success score #s2_moved zx.meta run tp @s ~ ~ ~
execute if score #s2_moved zx.meta matches 1 at @s run function fallendream:equipment/armor/empty_cicada/moved
scoreboard players set #bb_support zx.meta 1
execute if block ~ ~-0.01 ~ #minecraft:replaceable run scoreboard players set #bb_support zx.meta 0

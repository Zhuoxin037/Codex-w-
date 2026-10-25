# marker记录预检落点后由start复原到施放起点。
tp @s ~ ~ ~
scoreboard players set #bb_support zx.meta 1
execute if block ~ ~-0.01 ~ #minecraft:replaceable run scoreboard players set #bb_support zx.meta 0

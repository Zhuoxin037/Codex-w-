tag @e[tag=zx.s2_hit,distance=..10] remove zx.s2_hit
summon minecraft:marker ~ ~ ~ {Tags:["zx.s2_origin"]}
execute rotated ~ 0 positioned ^ ^ ^1 run summon minecraft:marker ~ ~ ~ {Tags:["zx.s2_axis"]}
execute store result score #s2_px zx.meta run data get entity @e[tag=zx.s2_origin,distance=..1,limit=1] Pos[0] 10
execute store result score #s2_pz zx.meta run data get entity @e[tag=zx.s2_origin,distance=..1,limit=1] Pos[2] 10
execute store result score #s2_px100 zx.meta run data get entity @e[tag=zx.s2_origin,distance=..1,limit=1] Pos[0] 100
execute store result score #s2_pz100 zx.meta run data get entity @e[tag=zx.s2_origin,distance=..1,limit=1] Pos[2] 100
execute store result score #s2_fx zx.meta run data get entity @e[tag=zx.s2_axis,distance=..2,limit=1] Pos[0] 100
execute store result score #s2_fz zx.meta run data get entity @e[tag=zx.s2_axis,distance=..2,limit=1] Pos[2] 100
scoreboard players operation #s2_fx zx.meta -= #s2_px100 zx.meta
scoreboard players operation #s2_fz zx.meta -= #s2_pz100 zx.meta
scoreboard players operation #s2_norm zx.meta = #s2_fx zx.meta
scoreboard players operation #s2_norm zx.meta *= #s2_fx zx.meta
scoreboard players operation #s2_temp zx.meta = #s2_fz zx.meta
scoreboard players operation #s2_temp zx.meta *= #s2_fz zx.meta
scoreboard players operation #s2_norm zx.meta += #s2_temp zx.meta
execute store result score #s2_py zx.meta run data get entity @e[tag=zx.s2_origin,distance=..1,limit=1] Pos[1] 10
kill @e[tag=zx.s2_axis,distance=..2]
kill @e[tag=zx.s2_origin,distance=..1]

scoreboard players set @s zx.weave_clock 20
scoreboard players remove @s zx.weave_left 1
scoreboard players add @s zx.weave_round 1
scoreboard players operation #weave_n zx.meta = @s zx.weave_n
scoreboard players operation #weave_round zx.meta = @s zx.weave_round
tag @e[tag=zx.weave_a,distance=0..] remove zx.weave_a
tag @e[tag=zx.weave_b,distance=0..] remove zx.weave_b
tag @e[tag=zx.weave_c,distance=0..] remove zx.weave_c
tag @e[tag=zx.weave_edge,distance=0..] remove zx.weave_edge
tag @e[tag=zx.weave_area,distance=0..] remove zx.weave_area
tag @e[tag=zx.weave_landed,distance=0..] remove zx.weave_landed
function fallendream:equipment/staff/star_weave/points with entity @s data
execute at @e[tag=zx.weave_a,limit=1,distance=0..] run tag @e[type=!#fallendream:no_damage,distance=..1.5] add zx.weave_edge
execute at @e[tag=zx.weave_b,limit=1,distance=0..] run tag @e[type=!#fallendream:no_damage,distance=..1.5] add zx.weave_edge
execute at @e[tag=zx.weave_c,limit=1,distance=0..] run tag @e[type=!#fallendream:no_damage,distance=..1.5] add zx.weave_edge
execute if score #weave_n zx.meta matches 2.. at @e[tag=zx.weave_a,limit=1,distance=0..] facing entity @e[tag=zx.weave_b,limit=1,distance=0..] feet run function fallendream:equipment/staff/star_weave/line_b
execute if score #weave_n zx.meta matches 3 at @e[tag=zx.weave_b,limit=1,distance=0..] facing entity @e[tag=zx.weave_c,limit=1,distance=0..] feet run function fallendream:equipment/staff/star_weave/line_c
execute if score #weave_n zx.meta matches 3 at @e[tag=zx.weave_c,limit=1,distance=0..] facing entity @e[tag=zx.weave_a,limit=1,distance=0..] feet run function fallendream:equipment/staff/star_weave/line_a
execute if score #weave_n zx.meta matches 3 run function fallendream:equipment/staff/star_weave/area_prepare
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute as @a[tag=zx.ub,scores={zx.job=1},distance=0..,limit=1] positioned ~ ~ ~ run function fallendream:equipment/staff/star_weave/damage
execute if score #weave_round zx.meta matches 1 run effect give @e[tag=zx.weave_landed,distance=0..] minecraft:slowness 2 1 true
tag @e[tag=zx.weave_a,distance=0..] remove zx.weave_a
tag @e[tag=zx.weave_b,distance=0..] remove zx.weave_b
tag @e[tag=zx.weave_c,distance=0..] remove zx.weave_c
tag @e[tag=zx.weave_edge,distance=0..] remove zx.weave_edge
tag @e[tag=zx.weave_area,distance=0..] remove zx.weave_area
tag @e[tag=zx.weave_landed,distance=0..] remove zx.weave_landed

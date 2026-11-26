summon minecraft:marker ~ ~ ~ {Tags:["zx.s2_aim_start"]}
execute positioned ^ ^ ^1 run summon minecraft:marker ~ ~ ~ {Tags:["zx.s2_aim_unit"]}
data modify storage zx:work s2_scene_origin.aim set value [0.0d,0.0d,0.0d]
scoreboard players set #s2_aim_len zx.meta 64
function fallendream:equipment/sword/mirrored_scene/aim_coordinate {i:0}
function fallendream:equipment/sword/mirrored_scene/aim_coordinate {i:1}
function fallendream:equipment/sword/mirrored_scene/aim_coordinate {i:2}
kill @e[tag=zx.s2_aim_start,distance=..2]
kill @e[tag=zx.s2_aim_unit,distance=..2]

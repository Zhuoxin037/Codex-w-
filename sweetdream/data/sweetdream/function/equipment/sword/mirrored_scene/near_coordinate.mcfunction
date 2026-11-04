$execute store result score #s2_near_from zx.meta run data get storage zx:work s2_scene_origin.pos[$(i)] 1000
$execute store result score #s2_near_to zx.meta run data get storage zx:work s2_scene_origin.aim[$(i)] 1000
scoreboard players operation #s2_near_to zx.meta -= #s2_near_from zx.meta
scoreboard players operation #s2_near_to zx.meta /= #s2_aim_div zx.meta
scoreboard players operation #s2_near_to zx.meta += #s2_near_from zx.meta
$execute store result storage zx:work s2_scene_origin.near[$(i)] double .001 run scoreboard players get #s2_near_to zx.meta

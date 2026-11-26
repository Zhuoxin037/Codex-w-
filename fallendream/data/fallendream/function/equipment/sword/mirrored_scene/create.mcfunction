$execute in $(dim) run summon minecraft:marker 0 0 0 {Tags:["zx.s2_scene_origin"],data:{}}
$execute in $(dim) run data modify entity @e[tag=zx.s2_scene_origin,limit=1] Pos set from storage zx:work s2_scene_origin.pos
$execute in $(dim) run summon minecraft:marker 0 0 0 {Tags:["zx.s2_scene_direction"]}
$execute in $(dim) run data modify entity @e[tag=zx.s2_scene_direction,limit=1] Pos set from storage zx:work s2_scene_origin.near
$execute in $(dim) at @e[tag=zx.s2_scene_origin,limit=1] facing entity @e[tag=zx.s2_scene_direction,limit=1] feet run function fallendream:equipment/sword/mirrored_scene/blade
$execute in $(dim) run kill @e[tag=zx.s2_scene_origin]
$execute in $(dim) run kill @e[tag=zx.s2_scene_direction]

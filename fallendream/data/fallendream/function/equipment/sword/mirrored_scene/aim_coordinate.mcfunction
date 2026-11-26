$execute store result score #s2_aim_base zx.meta run data get entity @e[tag=zx.s2_aim_start,distance=..2,limit=1] Pos[$(i)] 1000
$execute store result score #s2_aim_dir zx.meta run data get entity @e[tag=zx.s2_aim_unit,distance=..2,limit=1] Pos[$(i)] 1000
scoreboard players operation #s2_aim_dir zx.meta -= #s2_aim_base zx.meta
scoreboard players set #s2_aim_sign zx.meta 1
execute if score #s2_aim_dir zx.meta matches ..-1 run scoreboard players set #s2_aim_sign zx.meta -1
execute if score #s2_aim_sign zx.meta matches -1 run function fallendream:equipment/sword/mirrored_scene/negate
scoreboard players operation #mp_src zx.meta = #s2_aim_dir zx.meta
scoreboard players set #mp_mul zx.meta 64000
function fallendream:lib/math/mul_permille
scoreboard players operation #s2_aim_dir zx.meta = #mp_out zx.meta
execute if score #s2_aim_sign zx.meta matches -1 run function fallendream:equipment/sword/mirrored_scene/negate
scoreboard players operation #s2_aim_base zx.meta += #s2_aim_dir zx.meta
$execute store result storage zx:work s2_scene_origin.aim[$(i)] double .001 run scoreboard players get #s2_aim_base zx.meta

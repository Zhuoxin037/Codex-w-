$scoreboard players set #mp_src zx.meta $(primary)
scoreboard players set #mp_mul zx.meta 800
function fallendream:lib/math/mul_permille
execute if score #mp_out zx.meta matches ..0 run return 0
tag @e[tag=zx.im_main,distance=0..] remove zx.im_main
$tag $(main) add zx.im_main
$data modify storage zx:work a set value {target:"@e[type=!#fallendream:no_damage,tag=!zx.im_main,distance=..2]",fixed:1b,uncapped:1b,type:"fallendream:skill",attack_kind:"extra",chain:$(chain),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute store result storage zx:work a.num double 0.001 run scoreboard players get #mp_out zx.meta
function fallendream:lib/num/plain
function fallendream:internal/damage/with_from with storage zx:work a
tag @e[tag=zx.im_main,distance=0..] remove zx.im_main

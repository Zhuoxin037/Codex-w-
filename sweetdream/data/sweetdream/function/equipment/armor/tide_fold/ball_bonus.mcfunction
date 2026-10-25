# 穿墙法球追加最大魔力×0.02固定伤害，以fixed_add并入同次命中；归属与头盔判定沿用发射者。
execute unless entity @s[tag=zx.tf_pass] run return 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0
execute as @a[tag=zx.ub,limit=1] unless items entity @s armor.head *[minecraft:custom_data~{zx:["tide_fold"]}] run return 0
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/armor/tide_fold/ball_calc
scoreboard players set #tf_fixed zx.meta 0
execute if data storage zx:work a.fixed_add store result score #tf_fixed zx.meta run data get storage zx:work a.fixed_add 1000
scoreboard players operation #tf_fixed zx.meta += #tf_b zx.meta
execute store result storage zx:work a.fixed_add double 0.001 run scoreboard players get #tf_fixed zx.meta
tag @s add zx.tf_bonus
particle minecraft:splash ~ ~0.6 ~ 0.3 0.4 0.3 0.05 10

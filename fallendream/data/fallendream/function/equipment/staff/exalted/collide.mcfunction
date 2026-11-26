tag @e[tag=zx.ex_partner,distance=0..] remove zx.ex_partner
# 【合并窗口 0.35 → 0.70, 与 small_seek 的 0.30 成对】两尊相向靠近的相对速度
# 是 2×0.30 = 0.60 格/刻, 采样步长必须小于窗口才不会"一步跨过去、永远判不到"。
# 0.70 对 0.60 留了 0.10 的余量。★ 改小石像速度必须先改这里。
$tag @e[tag=zx.ex_small,tag=!zx.ex_self,distance=..0.7,sort=nearest,limit=1,nbt={data:{owner:"$(owner)"}}] add zx.ex_partner
execute unless entity @e[tag=zx.ex_partner,distance=0..,limit=1] run return 0
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute as @a[tag=zx.ub,distance=0..,limit=1] positioned ~ ~ ~ run function fallendream:equipment/staff/exalted/collision_damage
tag @e[tag=zx.ex_grave_used,distance=0..] remove zx.ex_grave_used
$tag @e[tag=zx.ex_grave,distance=..16,sort=nearest,limit=1,nbt={data:{owner:"$(owner)"}}] add zx.ex_grave_used
execute at @e[tag=zx.ex_grave_used,distance=0..,limit=1] if entity @e[tag=zx.ex_self,distance=..16] if entity @e[tag=zx.ex_partner,distance=..16] run tag @s add zx.ex_merge
execute if entity @s[tag=zx.ex_merge] at @s run function fallendream:equipment/staff/exalted/merge
tag @e[tag=zx.ex_grave_used,distance=0..] remove zx.ex_grave_used
tag @e[tag=zx.ex_partner,distance=0..,limit=1] remove zx.ex_small
tag @s remove zx.ex_small
# 两只都要跟各自的小石像一起消失 ⇒ 一律走 small_die, 别直接 kill。
# small_die 内部用 `sort=nearest,limit=1`, 所以各收各的: 先收 partner 的载体
# 再杀 partner, 然后收自己的再杀自己。这样不会出现"一只清了两个、另一只
# 留下个没有形体的光球"的错位(两只相距只有 0.70, 半径 0.8 是互相覆盖的)。
execute as @e[tag=zx.ex_partner,distance=0..,limit=1] at @s run function fallendream:equipment/staff/exalted/small_die
function fallendream:equipment/staff/exalted/small_die

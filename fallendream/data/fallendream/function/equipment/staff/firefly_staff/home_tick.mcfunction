# ============================================================
# fallendream:equipment/staff/firefly_staff/home_tick —— 环绕中的萤火每刻(宏 {angle,...})
# ------------------------------------------------------------
# 【执行者】环绕中的萤火(zx.ff_home)
# 【谁调用它】tick: `execute if entity @s[tag=zx.ff_home] run function …/home_tick with entity @s data`
# 【环绕位置】复用 follow 的写法: `at 主人 rotated <angle> 0 positioned ^ ^1.6 ^2.0`
#   —— 本地坐标的 x 是"主人的右手边", 所以 rotated 一改就是在主人身边转圈。
#   半径取 2.0(文案"围绕在自身 2 格")、高 1.6(大致在胸口高度绕着走)。
# 【碰触】1 格判定箱, 与飞行中同款; 唯一的区别是命中后走 explode 的"返回萤火"口径。
# 【到点】8 秒(160 刻)后直接消失 —— 文案只写"持续 8 秒", 没写到点再炸一次。
# ============================================================

# ① 反查主人(下线 / 换维度 -> 这只萤火没有存在的意义)
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,distance=0..,limit=1] run return run kill @s

# ② 绕着主人转
$execute at @a[tag=zx.ub,distance=0..,limit=1] rotated $(angle) 0 positioned ^ ^1.6 ^2.0 run tp @s ~ ~ ~

# ③ 碰触检测(排除主人自己)
tag @a[tag=zx.ff_owner] remove zx.ff_owner
tag @a[tag=zx.ub,distance=0..,limit=1] add zx.ff_owner
tag @e[tag=zx.ff_hit,distance=0..] remove zx.ff_hit
execute at @s positioned ~-0.4 ~-0.4 ~-0.4 run tag @e[type=!#fallendream:no_damage,tag=!zx.ff_owner,dx=0.8,dy=0.8,dz=0.8] add zx.ff_hit
tag @a[tag=zx.ff_owner] remove zx.ff_owner
execute if entity @e[tag=zx.ff_hit,distance=0..] at @s run return run function fallendream:equipment/staff/firefly_staff/explode

# ④ 8 秒到点消失
scoreboard players remove @s zx.ff_home_age 1
execute if score @s zx.ff_home_age matches ..0 run kill @s

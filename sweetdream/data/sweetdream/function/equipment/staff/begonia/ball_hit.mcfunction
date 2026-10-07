# ============================================================
# sweetdream:equipment/staff/begonia/ball_hit —— 海棠普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(`function $(hit) with entity @s data`)
#   (@s = 法球本体, 位置 = 命中点)
#   ⚠️ 此刻 zx.ball_hit 标签还没摘(ball/hit 第 ⑦ 步才清) —— 命中的生物
#   就用 @e[tag=zx.ball_hit] 圈出来。
# 【技能原文(lore 逐字)】每次普攻命中后都会使其轻微吸引一次其 1 格内的至多 3 个生物。
#   “其”= 命中的那只生物: 它是吸引的**中心**, 被拉的是它 1 格内至多 3 个生物。
# 【怎么"吸引"】照 iridescent/eff_3 的 tp 式位移, 但方向相反:
#   eff_3 是背对来源走一格(击退), 这里是**朝向中心走 0.6 格**(吸引, 故"轻微")。
#   目标格不是可替换方块就不动(免得塞进方块卡住)。
# ============================================================

# ① 中心 = 命中的那只生物(取离球最近的一只)
tag @e[tag=zx.bg_center,distance=0..] remove zx.bg_center
execute as @e[tag=zx.ball_hit,distance=0..,sort=nearest,limit=1] run tag @s add zx.bg_center
execute unless entity @e[tag=zx.bg_center,distance=0..,limit=1] run return 0

# ② 圈"中心 1 格内的至多 3 个生物"(不含中心本身)
tag @e[tag=zx.bg_pull,distance=0..] remove zx.bg_pull
execute at @e[tag=zx.bg_center,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..1,tag=!zx.bg_center,sort=nearest,limit=3] add zx.bg_pull

# ③ 轻微吸引: 每个目标朝中心挪 0.6 格
execute as @e[tag=zx.bg_pull,distance=0..] at @s facing entity @e[tag=zx.bg_center,distance=0..,limit=1] feet positioned ^ ^ ^0.6 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~

# ④ 表现 + 清理
execute at @e[tag=zx.bg_center,distance=0..,limit=1] run particle minecraft:bubble ~ ~0.5 ~ 1.0 0.4 1.0 0.02 14 normal
execute at @e[tag=zx.bg_center,distance=0..,limit=1] run particle minecraft:nautilus ~ ~0.5 ~ 0.6 0.3 0.6 0.02 6 normal
tag @e[tag=zx.bg_center,distance=0..] remove zx.bg_center
tag @e[tag=zx.bg_pull,distance=0..] remove zx.bg_pull

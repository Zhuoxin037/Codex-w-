# ============================================================
# sweetdream:equipment/staff/gu_poison/ball_hit —— 蛊毒普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(`function $(hit) with entity @s data`)
#   (@s = 法球本体, 位置 = 命中点)
#   ⚠️ 此刻 zx.ball_hit 标签还没摘(ball/hit 第 ⑦ 步才清)。
# 【技能原文(lore 逐字)】每次普攻命中后都会使其获得「噬心」效果和 3 秒的缓慢Ⅱ。
# 【「噬心」走统一入口 tag/mark】(它会刷新 18 秒租约、头顶出图标)。
# 【缓慢Ⅱ】原版缓慢 amplifier=1 = Ⅱ, 时长 3 秒。
# ============================================================

# ① 给命中的生物「噬心」
data modify storage zx:work ic set value {target:"@e[tag=zx.ball_hit]",mark:"shixin"}
function sweetdream:tag/mark with storage zx:work ic

# ② 3 秒缓慢Ⅱ
execute as @e[tag=zx.ball_hit,distance=0..] run effect give @s minecraft:slowness 3 1 true

# ③ 表现
execute as @e[tag=zx.ball_hit,distance=0..] at @s run particle minecraft:witch ~ ~1 ~ 0.4 0.6 0.4 0.02 12 normal
execute as @e[tag=zx.ball_hit,distance=0..] at @s run particle minecraft:item_slime ~ ~0.8 ~ 0.3 0.4 0.3 0.05 6 normal

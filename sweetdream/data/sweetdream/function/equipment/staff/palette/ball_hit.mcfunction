# ============================================================
# sweetdream:equipment/staff/palette/ball_hit —— 调色盘普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(`function $(hit) with entity @s data`)
#   (@s = 法球本体, 位置 = 命中点)
# 【技能原文(lore 逐字)】每次普攻命中后都会随机积攒一种颜色。
#   颜色可以叠加，最多同时持有两种颜色。
# 【"随机一种"= 红/黄/蓝 各 1/3】走 lib/rnd(全局伪随机, 和攻击节奏脱钩),
#   %3 得 0/1/2, +1 得颜色码 1(红)/2(黄)/3(蓝)。
# 【"最多两种"= 玩家身上两个槽 zx.pal_c1 / zx.pal_c2】0 = 空;
#   有空的就写进那个空槽(先 c1 后 c2), 两个都满就**不再积攒**(多余的丢弃)。
#   同色可以占两个槽 -> "每有一个红色"那种"计数"是真按槽数数的。
# ============================================================

# ① 反查发射者(球上带 u0..u3) —— 攒颜色必须记在玩家身上
data modify storage zx:work fb set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work fb.u0 set from entity @s data.u0
data modify storage zx:work fb.u1 set from entity @s data.u1
data modify storage zx:work fb.u2 set from entity @s data.u2
data modify storage zx:work fb.u3 set from entity @s data.u3
function sweetdream:lib/find_by with storage zx:work fb
execute unless entity @a[tag=zx.mc_by,limit=1] run return 0

# ② 摇一种颜色(1..3)
function sweetdream:lib/rnd
scoreboard players operation #pal_col zx.meta = #rnd zx.meta
scoreboard players operation #pal_col zx.meta %= #3 zx.meta
scoreboard players add #pal_col zx.meta 1

# ③ 交给玩家自己写入空槽
execute as @a[tag=zx.mc_by,limit=1] at @s run function sweetdream:equipment/staff/palette/color_gain
tag @a remove zx.mc_by

# ④ 命中的小表现(抹上一笔颜色)
particle minecraft:effect ~ ~ ~ 0.25 0.25 0.25 0.02 6 normal

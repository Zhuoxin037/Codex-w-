# ============================================================
# sweetdream:equipment/bow/bone_breaker/blade_place —— 把这一把刀摆到"准星前绕圈"的那一档
# ------------------------------------------------------------
# 【执行者】刀刃(item_display)   【前置】zx.bb_a = 0..23; 主人已由 lib/u_by 打上 zx.ub
# 【★ 为什么是 24 条 if 而不是三角函数 ★】mcfunction 没有 sin/cos，而本地坐标
#   ^x ^y 的 x/y 正好是「视线的右 / 上」 ⇒ 在这两个轴上转圈 = 绕视线轴自转。
#   于是把 24 个档位的坐标**写死成字面量**，每刻只命中一条：零 NBT、零宏、零三角函数。
#   半径 1.2 格、准星前方 3.5 格；每刻 +1 档 = 15°/刻 ≈ 1.25 圈/秒。
# 【★ 为什么要 at 主人 + anchored eyes ★】刀刃的位置必须每刻**重新贴**主人；
#   少了这一段，刀会停在召唤那一刻的位置（坑：突进"只走几格"同族 —— 每个子步都要重刷 at）。
#   anchored eyes 让它从眼睛出发，"跟着准星"才是准星前而不是脚前。
# ============================================================

execute if score @s zx.bb_a matches 0 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^1.20 ^0.00 ^3.5
execute if score @s zx.bb_a matches 1 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^1.16 ^0.31 ^3.5
execute if score @s zx.bb_a matches 2 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^1.04 ^0.60 ^3.5
execute if score @s zx.bb_a matches 3 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^0.85 ^0.85 ^3.5
execute if score @s zx.bb_a matches 4 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^0.60 ^1.04 ^3.5
execute if score @s zx.bb_a matches 5 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^0.31 ^1.16 ^3.5
execute if score @s zx.bb_a matches 6 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^0.00 ^1.20 ^3.5
execute if score @s zx.bb_a matches 7 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-0.31 ^1.16 ^3.5
execute if score @s zx.bb_a matches 8 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-0.60 ^1.04 ^3.5
execute if score @s zx.bb_a matches 9 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-0.85 ^0.85 ^3.5
execute if score @s zx.bb_a matches 10 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-1.04 ^0.60 ^3.5
execute if score @s zx.bb_a matches 11 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-1.16 ^0.31 ^3.5
execute if score @s zx.bb_a matches 12 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-1.20 ^0.00 ^3.5
execute if score @s zx.bb_a matches 13 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-1.16 ^-0.31 ^3.5
execute if score @s zx.bb_a matches 14 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-1.04 ^-0.60 ^3.5
execute if score @s zx.bb_a matches 15 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-0.85 ^-0.85 ^3.5
execute if score @s zx.bb_a matches 16 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-0.60 ^-1.04 ^3.5
execute if score @s zx.bb_a matches 17 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^-0.31 ^-1.16 ^3.5
execute if score @s zx.bb_a matches 18 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^0.00 ^-1.20 ^3.5
execute if score @s zx.bb_a matches 19 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^0.31 ^-1.16 ^3.5
execute if score @s zx.bb_a matches 20 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^0.60 ^-1.04 ^3.5
execute if score @s zx.bb_a matches 21 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^0.85 ^-0.85 ^3.5
execute if score @s zx.bb_a matches 22 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^1.04 ^-0.60 ^3.5
execute if score @s zx.bb_a matches 23 at @a[tag=zx.ub,limit=1] anchored eyes run tp @s ^1.16 ^-0.31 ^3.5

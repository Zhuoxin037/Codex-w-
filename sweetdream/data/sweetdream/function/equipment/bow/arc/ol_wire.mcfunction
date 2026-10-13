# ============================================================
# sweetdream:equipment/bow/arc/ol_wire —— 超限·电弧: 「3 格宽电线」一步
# ------------------------------------------------------------
# 【谁调用它】ol_fire(起手 facing 伙伴) + 自己递归(每步 1.0 格)
# 【执行者】放电锚回查出来的 A 端(@s 全程不变); 【位置】= 当前走到的那一点
# 【与原版 wire 的唯一差别 = 宽度】原版 radius 0.6 / 步距 0.4(= 约 1 格宽);
#   超限 radius 1.5 / 步距 1.0(= 约 3 格宽)。步距 < 2×半径 保证采样球充分重叠,
#   合起来是一条连续、宽约 3 格的走廊, 不会掐"腰"。
# 【为什么另起一个文件而不改 wire】原版电弧(非超限)还要用那一条 1 格宽的走廊,
#   改 wire 会把原版一起改宽 —— 两版必须各走各的(照 discharge / ol_fire 的分流)。
# 【★ 停步判据为什么是 ≤1.0】步距就是 1.0: 剩余距离一旦 ≤ 一个步长就该停,
#   再走一步会越过伙伴(朝向是定死的, 越过后只会越走越远)。半径 1.5 > 1.0,
#   所以停在差最后一格的位置, 走廊仍然覆盖到伙伴本身。
# 【为什么要步数上限】同 wire: 递归没上限时朝向/伙伴异常会把该刻命令预算打满。
# ============================================================

# ① 本点周围 1.5 格内的生物记为"走廊成员"
tag @e[type=!#sweetdream:no_damage,distance=0..1.5] add zx.arc_on

# ② 电火花
particle minecraft:electric_spark ~ ~1.0 ~ 0.5 0.6 0.5 0.0 2 normal

# ③ 步数 +1; 到上限强制收工
scoreboard players add #arc_st zx.meta 1
execute if score #arc_st zx.meta matches 41.. run return 0

# ④ 还没够到伙伴 -> 沿朝向再走 1.0 格, 递归(朝向继承)
execute unless entity @e[tag=zx.arc_partner,distance=0..1.0,limit=1] positioned ^ ^ ^1.0 run function sweetdream:equipment/bow/arc/ol_wire

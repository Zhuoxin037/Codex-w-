# ============================================================
# sweetdream:equipment/bow/arc/wire —— 「电线」一步(从本只朝伙伴步进)
# ------------------------------------------------------------
# 【谁调用它】discharge 的 A 段; 之后自己递归(每步 0.4 格)
# 【执行者】受害者(@s 全程不变); 【位置】= 当前走到的那一点
# 【朝向】起点由调用方 `facing entity <伙伴> feet` 定死, 递归里**不再改朝向**
#   -> 每一步都沿同一条直线(和 cold_crow/step 同一套"positioned 递归"写法)。
# 【每步做三件事】
#   ① 把这一点周围 0.6 格内的生物记为"走廊成员"(zx.arc_on) —— 步距 0.4 < 2×0.6,
#      采样球充分重叠, 合起来就是一条连续、宽约 1 格的走廊, 不会掐"腰"。
#   ② 撒一把电火花(表现; 这就是"那道电线")
#   ③ 没到伙伴就再走 0.4 格 —— 距伙伴 ≤0.3 停; 另有 40 步硬上限兜底, 防朝向异常时死循环。
# 【为什么要步数上限】递归没有上限时, 一旦朝向/伙伴异常就会一直调下去,
#   把该刻的命令预算(65536)打满 -> 同刻后面的函数整段不跑("stopped due to limit")。
# ============================================================

# ① 本点走廊成员(走廊起点 = 本只, 所以本只必然被标上)
tag @e[type=!#sweetdream:no_damage,distance=0..0.6] add zx.arc_on

# ② 电火花
particle minecraft:electric_spark ~ ~1.0 ~ 0.2 0.25 0.2 0.0 1 normal

# ③ 步数 +1; 到上限强制收工
scoreboard players add #arc_st zx.meta 1
execute if score #arc_st zx.meta matches 41.. run return 0

# ④ 还没够到伙伴 -> 沿朝向再走 0.4 格, 递归(朝向继承)
execute unless entity @e[tag=zx.arc_partner,distance=0..0.3,limit=1] positioned ^ ^ ^0.4 run function sweetdream:equipment/bow/arc/wire

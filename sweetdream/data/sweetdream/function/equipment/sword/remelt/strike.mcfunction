# ============================================================
# sweetdream:equipment/sword/remelt/strike —— 熔解状态: 一次同步结算
# ------------------------------------------------------------
# 【执行者】玩家(位置在他身上)
# 【怎么选目标】先把"自身 8 格内全部生物"圈进 zx.rm_n, 再挑出带「夜火」的 zx.rm_y
#   —— 分两步是因为"带夜火"是原生标签, 选择器不能和 distance 之外的第二个 tag 一起写。
# 【为什么要先冻结标签】否则下面"伤害"和"融甲"两次求值可能作用在不同的范围上。
# ============================================================

tag @e[tag=zx.rm_n] remove zx.rm_n
tag @e[tag=zx.rm_y] remove zx.rm_y
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8] add zx.rm_n
execute as @e[tag=zx.rm_n] if entity @s[tag=zx.status.yehuo] run tag @s add zx.rm_y
tag @e[tag=zx.rm_n] remove zx.rm_n

execute if entity @e[tag=zx.rm_y] run function sweetdream:equipment/sword/remelt/strike_go

tag @e[tag=zx.rm_y] remove zx.rm_y

# ============================================================
# sweetdream:equipment/axe/thunderclap/domain_keep —— 领域孤儿兜底(每刻, 执行者 = 领域)
# ------------------------------------------------------------
# 【谁调用它】core/tick 的兜底三条(每维度各一遍, 只筛 zx.tc_dom)
# 【做什么】读自己 data.zx.m 里记的"所属术阵 marker UUID", 交给父级宏去查那座 marker
# 【为什么要有这一层(非宏)】宏变量要先写进 storage 才能传给宏函数, 本函数只做这件事。
# 【★★ 修 F17 的另一半 ★★】
#   旧兜底是 `unless entity @e[tag=zx.tc_field,distance=..2]` —— 邻居术阵的 marker
#   会把"已经该收的孤儿领域"一直喂活(域模型永久残留); 现在改成按 UUID 找**自己那座**
#   marker, 与距离无关。
# ============================================================

data modify storage zx:work td set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work td.u0 set from entity @s data.zx.m[0]
data modify storage zx:work td.u1 set from entity @s data.zx.m[1]
data modify storage zx:work td.u2 set from entity @s data.zx.m[2]
data modify storage zx:work td.u3 set from entity @s data.zx.m[3]
function sweetdream:equipment/axe/thunderclap/domain_keep_go with storage zx:work td

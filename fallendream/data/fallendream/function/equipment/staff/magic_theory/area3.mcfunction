# ============================================================
# fallendream:equipment/staff/magic_theory/area3 —— 基础版爆炸范围(半径 3 格)
# ------------------------------------------------------------
# 【执行者】主人, 坐标在目标身上
# 【为什么要独立成文件】半径只能写选择器字面量, 不能按分数算 ⇒ 一般一档一个文件
# ============================================================
effect give @e[type=!#fallendream:no_damage,distance=..3] minecraft:weakness 3 1 true
data modify storage zx:work mt_area.target set value "@e[type=!#fallendream:no_damage,distance=..3]"

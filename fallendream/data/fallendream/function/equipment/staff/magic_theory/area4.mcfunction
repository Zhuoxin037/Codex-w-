# ============================================================
# fallendream:equipment/staff/magic_theory/area4 —— 超限版爆炸范围(半径 4 格)
# ------------------------------------------------------------
# 【执行者】主人, 坐标在目标身上
# 【口径】超限文案「追加一次半径 4 格、最大魔力值 ×0.1 的伤害, 并施加 3 秒虚弱Ⅱ」
#   虚弱仍为 3 秒 Ⅱ(amplifier 1), 只有半径从 3 涨到 4
# ============================================================
effect give @e[type=!#fallendream:no_damage,distance=..4] minecraft:weakness 3 1 true
data modify storage zx:work mt_area.target set value "@e[type=!#fallendream:no_damage,distance=..4]"

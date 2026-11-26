# ============================================================
# fallendream:equipment/sword/oath_victory/field_heal —— 领域内的每秒回复（执行者=玩家）
# ------------------------------------------------------------
# 【文案】"自身在领域内时每秒恢复 3 点生命值并获得相当于自身最大生命值 ×0.2 的临时生命值"
# 【★ 顺序 ★】先 lib/heal（3 点精确治疗），再算 20% 最大生命给临时生命。
#   lib/heal 会临时压 max_health（heal_cap），lib/max_health_score 已把它排除 ⇒ 两者
#   谁先谁后都不影响"最大生命"的读数，但先治疗后加临时生命更符合文案语序。
# ============================================================

scoreboard players set #heal_pt zx.meta 3
function fallendream:lib/heal

# 临时生命 = 最大生命 ×0.2
#   ★ 单位链（别写错，错一步就差 1000 倍）★ #max_hp 是**毫点**（×1000），
#   #thp_v 要的是**整点** ⇒ 先把毫点降成点（÷1000），再 ×20÷100 取两成。
#   即 20 点血 → 20×20÷100 = 4 点。曾经写成 ÷10×2（= 毫点的 20%）⇒ 给 4000 点。
function fallendream:lib/max_health_score
scoreboard players set #thp_v zx.meta 0
scoreboard players operation #thp_v zx.meta = #max_hp zx.meta
scoreboard players operation #thp_v zx.meta /= #1000 zx.meta
scoreboard players operation #thp_v zx.meta *= #20 zx.meta
scoreboard players operation #thp_v zx.meta /= #100 zx.meta
function fallendream:lib/thp/add

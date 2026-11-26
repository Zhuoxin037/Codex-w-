# ============================================================
# fallendream:equipment/armor/resonance/apply_mcm —— 写魔耗倍率(mana_cost_multiplier)
# ------------------------------------------------------------
# 【入参】#rs_d zx.meta = 差值(×1000; 目标 850 = ×0.85, 1000 = ×1.0)
# 【执行者】玩家   【要求】调用方已取好 lib/uuid
# 【★ 这是"倍率"不是"加算属性" ⇒ 直接 set, 不走 stats/add ★】
#   账本 zx.rs_mcm 先加上差值, 再把账本整体写成面板值 —— 这样反复进出
#   也不会累积漂移(每次写的都是绝对值)。
# 【★ 为什么用宏写 ★】数据路径里带 UUID, 只能用宏占位符拼。
# ============================================================

scoreboard players operation @s zx.rs_mcm += #rs_d zx.meta
data modify storage manacore:work mcm set value {uuid:"",v:1.0}
data modify storage manacore:work mcm.uuid set from storage zx:data self.uuid
execute store result storage manacore:work mcm.v double 0.001 run scoreboard players get @s zx.rs_mcm
function fallendream:equipment/armor/resonance/mcm_set with storage manacore:work mcm

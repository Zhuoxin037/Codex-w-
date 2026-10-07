# ============================================================
# sweetdream:upgrade/item/mana_surge_a —— 给一块「魔力沸涌·α」
# ------------------------------------------------------------
# 【custom_data】标记 up_mana_surge_a, 进度 advancement/upgrade/mana_surge_a 认它。
# 【为什么不带 itemreplace】材料是一次性消耗品, 带上会被还回来(见 coolant_a 注释)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】recovery_compass + custom_model_data 编号 14(★ floats:[14.0f] 不能写成 [14])。
# 【图标已画】朱红液滴(mana_surge 系列 α), 编号 14(字母显示 α/β/Ω, β 另加四角点)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
# 【★ 名字撞车警告】已存在 mana_up_* (魔力提升) 和 mana_gain_* (魔力增殖) 两个系列,
#   本系列是 mana_surge_* (魔力沸涌), 三码完全不同, 别写混。
# 【效果已实装】apply/mana_surge_a + def/load 已登记, 效果见 upgrade/api(2026-10-07)。
# 【★ 是"每 3 秒 -1 秒"的持续效果】要挂 manacore:event/second 判魔力百分比,
#   不是一次性减冷却。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"魔力沸涌·α",bold:true,color:light_purple},custom_model_data={floats:[14.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧 / 法杖","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"无","color":"aqua"}]},{"text":" ","italic":false},{"text":"自身魔力值低于 20% 时，自身技能冷却时","color":"gray","italic":false},{"text":"间每 3 秒 -1 秒。","color":"gray","italic":false}],custom_data={zx:["up_mana_surge_a"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

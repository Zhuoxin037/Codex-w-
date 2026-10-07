# ============================================================
# sweetdream:upgrade/item/mana_surge_o —— 给一块「魔力沸涌·Ω」
# ------------------------------------------------------------
# 【custom_data】标记 up_mana_surge_o, 进度 advancement/upgrade/mana_surge_o 认它。
# 【前置】必须已敲入「魔力沸涌·β」—— 由 apply/mana_surge_o 校验(本文件只发物品)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】recovery_compass + custom_model_data 编号 16(★ floats:[16.0f] 不能写成 [16])。
# 【图标已画】朱红液滴(mana_surge 系列 Ω), 编号 16(字母显示 α/β/Ω, β 另加四角点)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
# 【效果已实装】apply/mana_surge_o + def/load 已登记, 效果见 upgrade/api(2026-10-07)。
# 【Ω 相对 β 只有门槛变了】30% -> 50%, 间隔仍是 2 秒 —— 别顺手把间隔也改成 1 秒。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"魔力沸涌·Ω",bold:true,color:light_purple},custom_model_data={floats:[16.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧 / 法杖","color":"yellow"}]},{"text":"","italic":false,"extra":[{"text":"前置 ","color":"gray"},{"text":"魔力沸涌·β","color":"aqua"}]},{"text":" ","italic":false},{"text":"自身魔力值低于 50% 时，自身技能冷却时","color":"gray","italic":false},{"text":"间每 2 秒 -1 秒。","color":"gray","italic":false}],custom_data={zx:["up_mana_surge_o"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

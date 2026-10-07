# ============================================================
# sweetdream:upgrade/item/coolant_b —— 给一块「冷却剂·β」
# ------------------------------------------------------------
# 【custom_data】标记 up_coolant_b, 进度 advancement/upgrade/coolant_b 认它。
# 【前置】必须已敲入「冷却剂·α」—— 由 apply/coolant_b 校验(本文件只发物品)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】recovery_compass + custom_model_data 编号 9(★ floats:[9.0f] 不能写成 [9])。
# 【图标已画】冰蓝雪花(coolant 系列 β), 编号 9(字母显示 α/β/Ω, β 另加四角点)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
# 【效果已实装】apply/coolant_b + def/load 已登记, 效果见 upgrade/api(2026-10-07)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"冷却剂·β",bold:true,color:light_purple},custom_model_data={floats:[9.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧 / 法杖","color":"yellow"}]},{"text":"","italic":false,"extra":[{"text":"前置 ","color":"gray"},{"text":"冷却剂·α","color":"aqua"}]},{"text":" ","italic":false},{"text":"武器主动技能冷却时间 -10%。","color":"gray","italic":false}],custom_data={zx:["up_coolant_b"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

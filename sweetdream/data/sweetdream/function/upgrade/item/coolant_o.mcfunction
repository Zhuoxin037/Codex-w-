# ============================================================
# sweetdream:upgrade/item/coolant_o —— 给一块「冷却剂·Ω」
# ------------------------------------------------------------
# 【custom_data】标记 up_coolant_o, 进度 advancement/upgrade/coolant_o 认它。
# 【前置】必须已敲入「冷却剂·β」—— 由 apply/coolant_o 校验(本文件只发物品)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】recovery_compass + custom_model_data 编号 10(★ floats:[10.0f] 不能写成 [10])。
# 【图标已画】冰蓝雪花(coolant 系列 Ω), 编号 10(字母显示 α/β/Ω, β 另加四角点)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
# 【效果已实装】apply/coolant_o + def/load 已登记, 效果见 upgrade/api(2026-10-07)。
# 【Ω 的第二段怎么落】"每秒 -1 秒"由 upgrade/api/cd_tick 每秒结算(读主手 custom_data.skill, 只减本武器那个技能), 不是一次性 -20%(2026-10-07)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"冷却剂·Ω",bold:true,color:light_purple},custom_model_data={floats:[10.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧 / 法杖","color":"yellow"}]},{"text":"","italic":false,"extra":[{"text":"前置 ","color":"gray"},{"text":"冷却剂·β","color":"aqua"}]},{"text":" ","italic":false},{"text":"武器主动技能冷却时间 -20%。若技能冷却","color":"gray","italic":false},{"text":"时间大于 30 秒，则每秒技能冷却时间额","color":"gray","italic":false},{"text":"外 -1 秒。","color":"gray","italic":false}],custom_data={zx:["up_coolant_o"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

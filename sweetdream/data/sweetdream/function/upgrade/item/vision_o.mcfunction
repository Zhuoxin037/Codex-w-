# ============================================================
# sweetdream:upgrade/item/vision_o —— 给一块「愿景·Ω」
# ------------------------------------------------------------
# 【custom_data】标记 up_vision_o, 进度 advancement/upgrade/vision_o 认它。
# 【前置】必须已敲入「愿景·β」—— 由 apply/vision_o 校验(本文件只发物品)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】recovery_compass + custom_model_data 编号 19(★ floats:[19.0f] 不能写成 [19])。
# 【图标已画】金瞳眼形(vision 系列 Ω), 编号 19(字母显示 α/β/Ω, β 另加四角点)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
# 【效果已实装】apply/vision_o + def/load 已登记, 效果见 upgrade/api(2026-10-07)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"愿景·Ω",bold:true,color:light_purple},custom_model_data={floats:[19.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧 / 弓 / 法杖","color":"yellow"}]},{"text":"","italic":false,"extra":[{"text":"前置 ","color":"gray"},{"text":"愿景·β","color":"aqua"}]},{"text":" ","italic":false},{"text":"技能伤害提升 30%。","color":"gray","italic":false}],custom_data={zx:["up_vision_o"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

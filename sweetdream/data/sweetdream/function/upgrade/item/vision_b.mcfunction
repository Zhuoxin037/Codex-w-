# ============================================================
# sweetdream:upgrade/item/vision_b —— 给一块「愿景·β」
# ------------------------------------------------------------
# 【custom_data】标记 up_vision_b, 进度 advancement/upgrade/vision_b 认它。
# 【前置】必须已敲入「愿景·α」—— 由 apply/vision_b 校验(本文件只发物品)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】recovery_compass + custom_model_data 编号 18(★ floats:[18.0f] 不能写成 [18])。
# 【图标已画】金瞳眼形(vision 系列 β), 编号 18(字母显示 α/β/Ω, β 另加四角点)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
# 【效果已实装】apply/vision_b + def/load 已登记, 效果见 upgrade/api(2026-10-07)。
# 【★ β 是"变成 20%"不是"再加 20%】三档是替换关系(10%/20%/30%), 敲入 β 时要把
#   α 的 10% 撤掉再上 20%, 别做成 30%。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"愿景·β",bold:true,color:light_purple},custom_model_data={floats:[18.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧 / 弓 / 法杖","color":"yellow"}]},{"text":"","italic":false,"extra":[{"text":"前置 ","color":"gray"},{"text":"愿景·α","color":"aqua"}]},{"text":" ","italic":false},{"text":"技能伤害提升 20%。","color":"gray","italic":false}],custom_data={zx:["up_vision_b"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

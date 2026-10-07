# ============================================================
# sweetdream:upgrade/item/harden_b —— 给一块「硬化·β」
# ------------------------------------------------------------
# 【custom_data】标记 up_harden_b, 进度 advancement/upgrade/harden_b 认它。
# 【前置】必须已敲入「硬化·α」—— 由 apply/harden_b 校验(本文件只发物品)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】recovery_compass + custom_model_data 编号 12(★ floats:[12.0f] 不能写成 [12])。
# 【图标已画】钢银盾形(harden 系列 β), 编号 12(字母显示 α/β/Ω, β 另加四角点)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
# 【效果已实装】apply/harden_b + def/load 已登记, 效果见 upgrade/api(2026-10-07)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"硬化·β",bold:true,color:light_purple},custom_model_data={floats:[12.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"盔甲","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"硬化·α","color":"aqua"}]},{"text":" ","italic":false},{"text":"护甲值 +4，护甲韧性 +1。","color":"gray","italic":false}],custom_data={zx:["up_harden_b"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

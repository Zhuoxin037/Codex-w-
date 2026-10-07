# ============================================================
# sweetdream:upgrade/item/harden_a —— 给一块「硬化·α」
# ------------------------------------------------------------
# 【custom_data】标记 up_harden_a, 进度 advancement/upgrade/harden_a 认它。
# 【为什么不带 itemreplace】材料是一次性消耗品, 带上会被还回来(见 coolant_a 注释)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】recovery_compass + custom_model_data 编号 11(★ floats:[11.0f] 不能写成 [11])。
# 【图标已画】钢银盾形(harden 系列 α), 编号 11(字母显示 α/β/Ω, β 另加四角点)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
# 【效果已实装】apply/harden_a + def/load 已登记, 效果见 upgrade/api(2026-10-07)。
# 【★ 护甲值和本包的关系】本包盔甲的属性加成走"账本"机制(见 armor/*/passive),
#   护甲值本身是原版属性 minecraft:armor —— 敲入时直接改物品 attribute_modifiers 即可,
#   不用走账本。做效果时先确认现有盔甲有没有已占用的 modifier id, 别撞车。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"硬化·α",bold:true,color:light_purple},custom_model_data={floats:[11.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"盔甲","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"无","color":"aqua"}]},{"text":" ","italic":false},{"text":"护甲值 +2。","color":"gray","italic":false}],custom_data={zx:["up_harden_a"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

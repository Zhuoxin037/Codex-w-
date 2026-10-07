# ============================================================
# sweetdream:upgrade/item/coolant_a —— 给一块「冷却剂·α」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 up_coolant_a :
#   进度 advancement/upgrade/coolant_a 靠它认"右键用掉了哪块石头"。
# 【为什么不带 itemreplace】那是"通用回手线"的标记(右键用完还手),
#   材料是一次性消耗品, 带上它会被还回来 —— 敲失败时才需要还(见 apply/)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】统一 recovery_compass(追溯指针)—— 唯一不会被任何配方当原料吃掉的底座。
#   custom_model_data 是它的"图标编号", 资源包靠这个换外观。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 一一对应, 改一边要改两边。
#   ★ 必须写成 floats:[8.0f]: component 的 floats 是 Float 列表,
#     直接给 [8] 是整型列表, 会被 codec 拒掉。
# 【图标已画】冰蓝雪花(coolant 系列 α), 编号 8(字母显示 α/β/Ω, β 另加四角点)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
# 【效果已实装】apply/coolant_a + def/load 已登记, 效果见 upgrade/api(2026-10-07)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"冷却剂·α",bold:true,color:light_purple},custom_model_data={floats:[8.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧 / 法杖","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"无","color":"aqua"}]},{"text":" ","italic":false},{"text":"武器主动技能冷却时间 -5%。","color":"gray","italic":false}],custom_data={zx:["up_coolant_a"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

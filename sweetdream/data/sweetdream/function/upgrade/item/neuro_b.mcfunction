# ============================================================
# sweetdream:upgrade/item/neuro_b —— 给一块「神经衰弱·β」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 up_neuro_b :
#   进度 advancement/upgrade/neuro_b 靠它认"右键用掉了哪块石头"。
# 【为什么不带 itemreplace】那是"通用回手线"的标记(右键用完还手),
#   材料是一次性消耗品, 带上它会被还回来 —— 敲失败时才需要还(见 apply/neuro_b)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】统一 recovery_compass(追溯指针)—— 唯一不会被任何配方当原料吃掉的底座。
#   custom_model_data 是它的"图标编号", 资源包靠这个换外观,
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 一一对应, 改一边要改两边。
#   ★ 必须写成 floats:[51.0f]: component 的 floats 是 Float 列表,
#     直接给 [51] 是整型列表, 会被 codec 拒掉。
# 【图标】闪电形(神经衰弱 = 神经 / 电流), 编号 51。
#   重跑: python .workbuddy/_gen_stone_icons.py
# 【效果已实装】upgrade/def/load 的 updef."neuro_b" + upgrade/held_apply(2026-10-12)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"神经衰弱·β",bold:true,color:light_purple},custom_model_data={floats:[51.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"神经衰弱·α","color":"aqua"}]},{"text":" ","italic":false},{"text":"攻击速度 +0.2。","color":"gray","italic":false}],custom_data={zx:["up_neuro_b"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

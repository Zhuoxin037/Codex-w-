# ============================================================
# sweetdream:upgrade/item/torch —— 给一块「火炬」
# ------------------------------------------------------------
# 【custom_data】标记 up_torch, 进度 advancement/upgrade/torch 认它。
# 【为什么不带 itemreplace】材料是一次性消耗品, 带上会被还回来(见 coolant_a 注释)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】recovery_compass + custom_model_data 编号 23(★ floats:[23.0f] 不能写成 [23])。
# 【图标已画】橙金火苗(torch), 编号 23。画法/重跑: python .workbuddy/_gen_stone_icons.py
# 【效果已实装】apply/torch + def/load 已登记; 落地在 upgrade/api/torch(经 api/hit_mark)。
# 【★ 适用面】剑 / 斧 —— 和魔力增殖、冷却剂同款(cat:"sword", cat2:"axe")。
# 【★ 无 α/β/Ω】用户给的原文就是一块「火炬」, 没有分级; tier 1 / series:"torch" / req 空。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"火炬",bold:true,color:light_purple},custom_model_data={floats:[23.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"无","color":"aqua"}]},{"text":" ","italic":false},{"text":"攻击时若目标有「流火」效果，则有 10%","color":"gray","italic":false},{"text":"概率将其转换为「夜火」。","color":"gray","italic":false}],custom_data={zx:["up_torch"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

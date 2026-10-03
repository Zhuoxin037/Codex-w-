# ============================================================
# sweetdream:upgrade/item/mana_up_b —— 给一块「魔力提升·β」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 up_mana_up_b :
#   进度 advancement/upgrade/mana_up_b 靠它认"右键用掉了哪块石头"。
# 【为什么不带 itemreplace】那是"通用回手线"的标记(右键用完还手),
#   材料是一次性消耗品, 带上它会被还回来 —— 敲失败时才需要还(见 apply/mana_up_b)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】统一 recovery_compass(追溯指针)—— 唯一不会被任何配方当原料吃掉的底座。
#   custom_model_data 是它的"图标编号", 资源包靠这个换外观,
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 一一对应, 改一边要改两边。
#   ★ 必须写成 floats:[2.0f]: component 的 floats 是 Float 列表,
#     直接给 [2] 是整型列表, 会被 codec 拒掉。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"魔力提升·β",bold:true,color:dark_purple},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"盔甲","color":"yellow"}]},{"text":"","italic":false,"extra":[{"text":"前置 ","color":"gray"},{"text":"需要「魔力提升·α」","color":"red"}]},{"text":" ","italic":false},{"text":"自身魔力值上限 +30，且每秒额外恢复 2","color":"gray","italic":false},{"text":"点魔力值。","color":"gray","italic":false}],custom_data={zx:["up_mana_up_b"]},custom_model_data={floats:[2.0f]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

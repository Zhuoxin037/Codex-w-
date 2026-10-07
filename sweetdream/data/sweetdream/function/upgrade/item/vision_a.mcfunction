# ============================================================
# sweetdream:upgrade/item/vision_a —— 给一块「愿景·α」
# ------------------------------------------------------------
# 【custom_data】标记 up_vision_a, 进度 advancement/upgrade/vision_a 认它。
# 【为什么不带 itemreplace】材料是一次性消耗品, 带上会被还回来(见 coolant_a 注释)。
# 【consumable 不能删】没有它右键不会触发 consume_item 进度。
# 【底板】recovery_compass + custom_model_data 编号 17(★ floats:[17.0f] 不能写成 [17])。
# 【图标已画】金瞳眼形(vision 系列 α), 编号 17(字母显示 α/β/Ω, β 另加四角点)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
# 【效果已实装】apply/vision_a + def/load 已登记, 效果见 upgrade/api(2026-10-07)。
# 【★ 适用面最宽】剑 / 斧 / 弓 / 法杖 —— 四个类都能敲(冷却剂和魔力沸涌没有弓)。
#   def/load 登记时别漏了 bow。
# 【★ 加成口径】"技能伤害 +10%" —— 是全部技能, 不分基础攻击力/最大魔力值通道
#   (和 tool/seraph_wing 那种"只吃基础攻击力"的不一样)。实现时走全局伤害倍率槽。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"愿景·α",bold:true,color:light_purple},custom_model_data={floats:[17.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧 / 弓 / 法杖","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"无","color":"aqua"}]},{"text":" ","italic":false},{"text":"技能伤害提升 10%。","color":"gray","italic":false}],custom_data={zx:["up_vision_a"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

# ============================================================
# sweetdream:upgrade/item/life_up_a —— 给一块「生命提升·α」
# ------------------------------------------------------------
# 【custom_data】标记 up_life_up_a, 进度 advancement/upgrade/life_up_a 认它。
# 【底板】recovery_compass + custom_model_data 编号 26。
# 【图标已画】绯红圆盘 + 字母 α, 编号 26(β=27 加四角点, Ω=28 更亮配色)。
# 【效果已实装】apply/life_up_a + def/load 已登记。
# 【★ 不用另写落地 ★】定义表里的 hp 字段走的是**硬化石那条 ar/at/hp 账本**
#   (upgrade/armor_apply 的 ③ + api/hp_add), 写完定义就生效 —— 护甲/韧性/生命
#   三条共用同一套"目标值 - 已加值 = 差值"的账本。
# 【★ 分级链条】α(+2) -> β(+6) -> Ω(+10): 同系只认最高 tier, 所以 α+β 一起装
#   按 β 算(+6), 不是 +8。req 决定必须按序敲。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"生命提升·α",bold:true,color:light_purple},custom_model_data={floats:[26.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"盔甲","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"无","color":"aqua"}]},{"text":" ","italic":false},{"text":"最大生命值 +2。","color":"gray","italic":false}],custom_data={zx:["up_life_up_a"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

# ============================================================
# sweetdream:upgrade/item/life_up_o —— 给一块「生命提升·Ω」
# ------------------------------------------------------------
# 【custom_data】标记 up_life_up_o, 进度 advancement/upgrade/life_up_o 认它。
# 【底板】recovery_compass + custom_model_data 编号 28。
# 【★ 前置】req:"life_up_b" —— 必须先有 β。
# 【★ Ω 多一条: 常态再生Ⅰ ★】定义表里 rg:1, 由 upgrade/api/rg_now 落地
#   (和夜视仪同一条流水线, 都是"每 12 秒续一次")。
#   只有 Ω 有 —— 分级链条只认最高 tier, 穿 α+β 时 rg 读出来是 0。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"生命提升·Ω",bold:true,color:light_purple},custom_model_data={floats:[28.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"盔甲","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"生命提升·β","color":"aqua"}]},{"text":" ","italic":false},{"text":"最大生命值 +10，自身获得常态的再生效","color":"gray","italic":false},{"text":"果一。","color":"gray","italic":false}],custom_data={zx:["up_life_up_o"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

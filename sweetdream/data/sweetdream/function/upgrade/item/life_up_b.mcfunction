# ============================================================
# sweetdream:upgrade/item/life_up_b —— 给一块「生命提升·β」
# ------------------------------------------------------------
# 【custom_data】标记 up_life_up_b, 进度 advancement/upgrade/life_up_b 认它。
# 【底板】recovery_compass + custom_model_data 编号 27。
# 【★ 前置】req:"life_up_a" —— 那件盔甲上必须已经有 α 才敲得上(见 upgrade/api/fit ⑤)。
# 【★ 覆盖不是叠加】文案的"+6"是**这一级的完整效果**, 不是"在 α 的 2 上再加 6"
#   —— 分级链条保证只认最高 tier(见 upgrade/api/bonus_take)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"生命提升·β",bold:true,color:light_purple},custom_model_data={floats:[27.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"盔甲","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"生命提升·α","color":"aqua"}]},{"text":" ","italic":false},{"text":"最大生命值 +6。","color":"gray","italic":false}],custom_data={zx:["up_life_up_b"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

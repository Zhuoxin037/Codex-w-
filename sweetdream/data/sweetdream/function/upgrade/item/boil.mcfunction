# ============================================================
# sweetdream:upgrade/item/boil —— 给一块「沸腾」
# ------------------------------------------------------------
# 【custom_data】标记 up_boil, 进度 advancement/upgrade/boil 认它。
# 【底板】recovery_compass + custom_model_data 编号 24。
# 【图标已画】青蓝气泡(boil), 编号 24 —— 和「火炬」的橙金火苗是"冷热对仗"。
# 【效果已实装】apply/boil + def/load 已登记; 落地在 upgrade/api/boil(经 api/hit_mark)。
# 【★ "冻结 + 燃烧"怎么判】原版 NBT 的 TicksFrozen > 0 且 Fire > 0, 逐实体 data get
#   出来比 —— 不能写 {Fire:1..} 那种范围过滤器(1.21.5 会直接作废整个函数)。
# 【★ 真实伤害 = sweetdream:true_damage】无视护甲, 本包自己注册的伤害类型。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"沸腾",bold:true,color:light_purple},custom_model_data={floats:[24.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剑 / 斧","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"无","color":"aqua"}]},{"text":" ","italic":false},{"text":"自身每次攻击生物时，若其同时处于冻结","color":"gray","italic":false},{"text":"和燃烧状态则对其额外造成相当自身最大","color":"gray","italic":false},{"text":"魔力值 ×0.05 的真实伤害。","color":"gray","italic":false}],custom_data={zx:["up_boil"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

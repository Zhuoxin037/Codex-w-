# ============================================================
# fallendream:overlimit/item/beach_vein —— 给一块「超限·滩纹」
# 【接线】custom_data zx:["ol_beach_vein"] 供 advancement 识别；
#   CMD=96 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/beach_vein。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·滩纹",bold:true,color:light_purple},custom_model_data={floats:[96.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"滩纹","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后滩纹更名为「超限·滩纹」，自身魔","color":"gray","italic":false},{"text":"力值上限 +160。自身 5 格内有附有","color":"gray","italic":false},{"text":"「渊海」的生物时，自身护甲值 + 4，且","color":"gray","italic":false},{"text":"额外 + 10 %；若自身当前魔力值低于最大","color":"gray","italic":false},{"text":"魔力值的 50%，则每秒额外恢复 10 点魔","color":"gray","italic":false},{"text":"力值且自身护甲韧性 + 1。自身消耗","color":"gray","italic":false},{"text":"「渊海」后且范围内没有附有「渊海」的","color":"gray","italic":false},{"text":"生物时，上述护甲加成继续保留 6 秒。且","color":"gray","italic":false},{"text":"若此时魔力值低于最大魔力值的 50%，则","color":"gray","italic":false},{"text":"额外恢复一次 3% 魔力值。","color":"gray","italic":false}],custom_data={zx:["ol_beach_vein"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
